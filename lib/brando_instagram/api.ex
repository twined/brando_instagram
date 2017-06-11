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
  @url_base "https://api.instagram.com/v1"

  @doc """
  Main entry from genserver's `:poll`.
  Checks if we want `:user` or `:tags`
  """
  def query(state) do
    check_for_failed_downloads(state)
    do_query(state)
  end

  defp do_query(%State{filter: :blank, query: {:user, username}} = state) do
    images_for_user(username, state, min_id: 0)
    {:ok, InstagramImage.get_min_id}
  end

  defp do_query(%State{filter: filter, query: {:user, username}} = state) do
    images_for_user(username, state, min_id: filter)
    {:ok, InstagramImage.get_min_id}
  end

  defp do_query(%State{filter: :blank, query: {:tags, tags}} = state) do
    images_for_tags(tags, state, min_id: 0)
    {:ok, InstagramImage.get_min_id}
  end

  defp do_query(%State{filter: filter, query: {:tags, tags}} = state) do
    images_for_tags(tags, state, min_id: filter)
    {:ok, InstagramImage.get_min_id}
  end

  @doc """
  Get images for `username` by `min_id`.
  """
  def images_for_user(username, state, min_id: min_id) do
    case get_user_id(username, state) do
      {:ok, user_id} ->
        response = @http_lib.get(
          "#{@url_base}/users/#{user_id}/media/recent/" <>
          "?#{identifier(state)}" <>
          "&min_id=#{min_id}"
        )
        case response do
          {:ok, %{body: body, status_code: 200}} ->
            parse_images_for_user(body)
          {:ok, %{body: body, status_code: status_code}} ->
            {:error, "Instagram/images_for_user: #{inspect(status_code)} - #{inspect(body)}"}
          {:error, %{reason: reason}} ->
            {:error, "Error from HTTPoison: #{inspect(reason)}"}
        end
      {:error, errors} ->
        Logger.error("Instagram/images_for_user: #{inspect(errors)}")
    end
    :ok
  end

  @doc """
  Get images for `[tags]` by `min_timestamp`.
  """
  def images_for_tags(tags, state, min_id: min_id) do
    Enum.each tags, fn(tag) ->
      response = @http_lib.get(
        "#{@url_base}/tags/#{tag}/media/recent" <>
        "?#{identifier(state)}" <>
        "&min_tag_id=#{min_id}"
      )

      case response do
        {:ok, %{body: body, status_code: 200}} ->
          parse_images_for_tag(body)
        {:ok, %{body: body, status_code: status_code}} ->
          {:error, "Instagram/images_for_tags: #{inspect(status_code)} - #{inspect(body)}"}
        {:error, %{reason: reason}} ->
          {:error, "Error from HTTPoison: #{inspect(reason)}"}
      end
    end
    :ok
  end

  defp get_media(media_id, state) do
    response = @http_lib.get(
      "#{@url_base}/media/" <>
      "#{media_id}" <>
      "?#{identifier(state)}")

    case response do
      {:ok, %{body: body, status_code: 200}} ->
        parse_media(body)
      {:error, %{reason: reason}} ->
        {:error, "Error from HTTPoison: #{inspect(reason)}"}
    end
  end

  @doc """
  Get Instagram's user ID for `username`
  """
  def get_user_id(username, state) do
    response = @http_lib.get(
      "#{@url_base}/users/search?q=#{username}" <>
      "&#{identifier(state)}"
    )

    case response do
      {:ok, %{body: [{:data, [%{"id" => id}]} | _]}} ->
        {:ok, id}
      {:ok, %{body: [data: [], meta: %{}]}} ->
        {:error, "User not found: #{username}"}
      {:ok, %{body: {:error, error}}} ->
        {:error, "Instagram API error: #{inspect(error)}"}
      {:ok, %{body: [meta: %{"error_message" => _, "error_type" => "OAuthAccessTokenException"}], status_code: 400}} ->
        {:error, "Instagram access_token not valid."}
      {:ok, %{body: [meta: %{"error_message" => error_message}], status_code: 400}} ->
        {:error, "Instagram API 400 error: #{inspect(error_message)}"}
      {:ok, %{body: [{:data, multiple} | _]}} ->
        ret = for user <- multiple do
          Map.get(user, "username") == username && Map.get(user, "id") || ""
        end
        {:ok, Enum.join(ret)}
      {:ok, %{body: body, status_code: status_code}} ->
        {:error, "Instagram/get_user_id: #{inspect(status_code)} - #{inspect(body)}"}
      {:error, %{reason: reason}} ->
        {:error, "Error from HTTPoison: #{inspect(reason)}"}
    end
  end

  defp parse_media([data: data, meta: _meta]) do
    InstagramImage.store_image(data)
    :timer.sleep(Instagram.config(:sleep))
  end

  @doc """
  Store each image in `data` when we have tags. Ignore pagination (we
  could go on for years...)
  """
  def parse_images_for_tag([data: data, meta: _meta, pagination: _pagination]) do
    Enum.each data, fn(image) ->
      InstagramImage.store_image(image)
      # lets be nice and wait between each image stored.
      :timer.sleep(Instagram.config(:sleep))
    end
  end

  @doc """
  Store each image in `data`. Checks `pagination` for more images.
  """
  def parse_images_for_user([data: data, meta: _meta, pagination: _pagination]) do
    # Grab 20 latest images from DB and filter against data
    latest_images = InstagramImage.get_20_latest() || []

    Enum.each data, fn(image) ->
      unless image["id"] in latest_images do
        InstagramImage.store_image(image)
        # lets be nice and wait 5 seconds between storing images
        :timer.sleep(Instagram.config(:sleep))
      end
    end
  end

  @doc """
  Poison's callback for processing the json into a map
  """
  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, result}   ->
        Enum.map(result, fn({k, v}) -> {String.to_atom(k), v} end)
      {:error, :invalid, _} ->
        body
      {:error, errors} ->
        {:error, errors}
    end
  end

  defp check_for_failed_downloads(state) do
    for failed <- InstagramImage.get_failed_downloads() do
      get_media(failed.instagram_id, state)
    end
  end

  defp identifier(%State{access_token: token}) do
    "access_token=#{token}"
  end
end
