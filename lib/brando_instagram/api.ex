defmodule Brando.Instagram.API do
  @moduledoc """
  API functions for Instagram
  """
  use HTTPoison.Base
  require Logger

  alias Brando.Instagram
  alias Brando.InstagramImage
  alias Brando.Instagram.Server.State

  @http_lib Keyword.get(Application.get_env(:brando, Brando.Instagram, []), :api_http_lib, Instagram.API)
  @url_base "https://www.instagram.com"

  @doc """
  Main entry from genserver's `:poll`.
  Checks if we want `:user` or `:tag`
  """
  def query(state) do
    check_for_failed_downloads()
    do_query(state)
  end

  defp do_query(%State{query: {:user, username}}) do
    images_for_user(username)
  end

  defp do_query(%State{query: {:tag, tag}}) do
    images_for_tag(tag)
  end

  @doc """
  Get images for `username` by `min_id`.
  """
  def images_for_user(username) do
    response = @http_lib.get(
      "#{@url_base}/#{username}/" # <> "&min_id=#{min_id}"
    )

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        parse_images_for_user(body)
     {:ok, %{body: body, status_code: status_code}} ->
        {:error, "Instagram/images_for_user: #{inspect(status_code)} - #{inspect(body)}"}
      {:error, %{reason: reason}} ->
        {:error, "Error from HTTPoison: #{inspect(reason)}"}
    end
    :ok
  end

  @doc """
  Get images for `tag`
  """
  def images_for_tag(tag) do
    response = @http_lib.get(
      "#{@url_base}/tags/#{tag}/media/recent"
    )

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        parse_images_for_tag(body)
      {:ok, %{body: body, status_code: status_code}} ->
        {:error, "Instagram/images_for_tag: #{inspect(status_code)} - #{inspect(body)}"}
      {:error, %{reason: reason}} ->
        {:error, "Error from HTTPoison: #{inspect(reason)}"}
    end
    :ok
  end

  @doc """
  Store each image in `data` when we have tag.
  """
  def parse_images_for_tag([data: data, meta: _meta, pagination: _pagination]) do
    Enum.each data, fn(image) ->
      InstagramImage.store_image(image)
      # lets be nice and wait between each image stored.
      :timer.sleep(Instagram.config(:sleep))
    end
  end

  @doc """
  Store each image in `data`
  """
  def parse_images_for_user(data) do
    with [json] <- Regex.run(~r/>window\._sharedData = (.*);</, data, capture: :all_but_first),
         {:ok, s} <- Poison.decode(json),
         {:ok, images} <- parse_images_for_user_from_map(s) do
      # Grab 20 latest images from DB and filter against data
      latest_images = InstagramImage.get_20_latest() || []

      Enum.each images, fn(image) ->
        unless image.instagram_id in latest_images do
          InstagramImage.store_image(image)
          # lets be nice and wait 5 seconds between storing images
          :timer.sleep(Instagram.config(:sleep))
        end
      end
    else
      _ ->
        Logger.error "Instagram/parse_images_for_user: No usable json found"
    end
  end

  defp parse_images_for_user_from_map(%{"entry_data" => %{"ProfilePage" => [%{"graphql" => %{"user" => %{"username" => username, "id" => user_id, "edge_owner_to_timeline_media" => %{"edges" => data}}}}]}}) do
    images = Enum.map(data, fn (entry) ->
      node = entry["node"]
      %{
        url_original: node["display_url"],
        url_thumbnail: node["thumbnail_src"],
        instagram_id: "#{node["id"]}_#{user_id}",
        link: get_link(node),
        created_time: to_string(node["taken_at_timestamp"]),
        type: convert_type(node["__typename"]),
        username: username,
        caption: get_caption(node)
      }
    end)
    {:ok, images}
  end

  defp convert_type("GraphSidecar"), do: "carousel"
  defp convert_type("GraphVideo"), do: "video"
  defp convert_type("GraphImage"), do: "image"

  defp get_caption(%{"edge_media_to_caption" => %{"edges" => [%{"node" => %{"text" => caption}}]}}), do: caption
  defp get_caption(_), do: ""

  defp get_link(%{"shortcode" => shortcode}), do: "https://www.instagram.com/p/#{shortcode}/"

  defp check_for_failed_downloads() do
    for failed <- InstagramImage.get_failed_downloads() do
      require Logger
      Logger.error "--> trying to refetch #{failed.instagram_id}"
      InstagramImage.redownload_image(failed)
      :timer.sleep(Instagram.config(:sleep))
    end
  end
end
