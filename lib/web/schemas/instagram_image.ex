defmodule Brando.InstagramImage do
  @moduledoc """
  Ecto schema for the InstagramImage schema
  and helper functions for dealing with the schema.
  """

  @type t :: %__MODULE__{}

  use Brando.Web, :schema
  require Logger
  alias Brando.Instagram
  import Brando.Instagram.Gettext
  import Ecto.Query, only: [from: 2]

  @cfg Application.get_env(:brando, Brando.Instagram, [])
  @http_lib Keyword.get(@cfg, :api_http_lib, Instagram.API)

  @required_fields ~w(instagram_id link url_original username url_thumbnail created_time type status)a
  @optional_fields ~w(image caption)a

  schema "instagramimages" do
    field :instagram_id, :string
    field :type, :string
    field :caption, :string
    field :link, :string
    field :username, :string
    field :url_original, :string
    field :url_thumbnail, :string
    field :image, Brando.Type.Image
    field :created_time, :string
    field :status, Brando.Type.InstagramStatus, default: :rejected
  end

  @doc """
  Casts and validates `params` against `schema` to create a valid
  changeset when action is :create.

  ## Example

      schema_changeset = changeset(%__MODULE__{}, :create, params)

  """
  @spec changeset(t, :create, Keyword.t | Options.t) :: t
  def changeset(schema, :create, params) do
    status =
      case params["image"] do
        nil -> :download_failed
        _   -> @cfg[:auto_approve] && :approved || :rejected
      end

    schema
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:instagram_id)
    |> put_change(:status, status)
  end

  @doc """
  Casts and validates `params` against `schema` to create a valid
  changeset when action is :update.

  ## Example

      schema_changeset = changeset(%__MODULE__{}, :update, params)

  """
  @spec changeset(t, :update, %{binary => term} | %{atom => term}) :: t
  def changeset(schema, :update, params) do
    status =
      if schema.status == :download_failed && params["image"] do
        @cfg[:auto_approve] && :approved || :rejected
      else
        schema.status
      end

    schema
    |> cast(params, @required_fields ++ @optional_fields)
    |> put_change(:status, status)
  end

  @doc """
  Create a changeset for the schema by passing `params`.
  If not valid, return errors from changeset
  """
  @spec create(%{binary => term} | %{atom => term}) :: {:ok, t} | {:error, Keyword.t}
  def create(params) do
    image = Brando.repo.get_by(__MODULE__, instagram_id: params["instagram_id"] ||
                                                         params[:instagram_id])
    if image do
      image
      |> changeset(:update, params)
      |> Brando.repo.update
    else
      %__MODULE__{}
      |> changeset(:create, params)
      |> Brando.repo.insert
    end
  end

  @doc """
  Create an `update` changeset for the schema by passing `params`.
  If valid, update schema in Brando.repo.
  If not valid, return errors from changeset
  """
  @spec update(t, %{binary => term} | %{atom => term}) :: {:ok, t} | {:error, Keyword.t}
  def update(schema, params) do
    schema_changeset = changeset(schema, :update, params)
    if schema_changeset.valid? do
      {:ok, Brando.repo.update!(schema_changeset)}
    else
      {:error, schema_changeset.errors}
    end
  end

  @doc """
  Takes a map provided from the API and transforms it to a map we can
  use to store in the DB.
  """
  @spec store_image(%{binary => term}) :: {:ok, t} | {:error, Keyword.t}
  def store_image(%{"id" => instagram_id, "caption" => caption, "user" => user,
                    "images" => %{"thumbnail" => %{"url" => thumb},
                    "standard_resolution" => %{"url" => org}}} = image) do

    image
    |> Map.merge(%{"username" => user["username"],
                   "instagram_id" => instagram_id,
                   "caption" => caption && caption["text"] || "",
                   "url_thumbnail" => strip_q(thumb), "url_original" => strip_q(org)})
    |> Map.drop(["images", "id"])
    |> download_image
    |> create_image_sizes
    |> create
  end

  defp strip_q(url) do
    url
    |> String.split("?")
    |> List.first
  end

  def redownload_image(image) do
    params =
      image
      |> download_image
      |> create_image_sizes

    update(image, params)
  end

  defp download_image(%{"url_original" => url} = image) do
    case @http_lib.get(url) do
      {:ok, %{body: _, status_code: 404}} ->
        Logger.error(gettext("Instagram: Instagram API error. Download failed.\nURL: %{url}", url: url))
        Map.merge(image, %{"image" => nil, "status" => :download_failed})
      {:ok, %{body: {:error, :invalid}, status_code: 200}} ->
        Logger.error(gettext("Instagram: Instagram INVALID error. Download failed.\nURL: %{url}", url: url))
        Map.merge(image, %{"image" => nil, "status" => :download_failed})
      {:ok, %{body: body, status_code: 200}} ->
        media_path = Brando.config(:media_path)
        instagram_path = Instagram.config(:upload_path)
        path = Path.join([media_path, instagram_path])
        File.mkdir_p!(path)
        File.write!(Path.join([path, Path.basename(url)]), body)
        image_field = Map.put(%Brando.Type.Image{}, :path, Path.join([instagram_path, Path.basename(url)]))
        Map.put(image, "image", image_field)
      {:error, err} ->
        {:error, err}
    end
  end

  defp create_image_sizes(%{"image" => nil} = image_schema) do
    image_schema
  end

  defp create_image_sizes(image_schema) do
    sizes_cfg = Brando.Instagram.config(:sizes)
    if sizes_cfg != nil do
      image_field = image_schema["image"]
      media_path = Brando.config(:media_path)

      full_path = Path.join([media_path, image_field.path])
      {file_path, filename} = Brando.Utils.split_path(full_path)

      sizes = for {size_name, size_cfg} <- sizes_cfg do
        size_dir = Path.join([file_path, to_string(size_name)])
        File.mkdir_p(size_dir)
        sized_image = Path.join([size_dir, filename])
        Brando.Images.Utils.create_image_size(full_path, sized_image, size_cfg)
        sized_path = Path.join([Brando.Instagram.config(:upload_path), to_string(size_name), filename])
        {size_name, sized_path}
      end

      image_field = Map.put(image_field, :sizes, Enum.into(sizes, %{}))
      Map.put(image_schema, "image", image_field)
    else
      image_schema
    end
  end

  @doc """
  Get timestamp from where we search for new images
  """
  @spec get_last_created_time() :: :blank | String.t
  def get_last_created_time do
    max_ts = Brando.repo.one(
      from m in __MODULE__,
        select: m.created_time,
        order_by: [desc: m.created_time],
        limit: 1
    )

    case max_ts do
      nil ->
        :blank
      max_ts ->
        max_ts
        |> String.to_integer
        |> Kernel.+(1)
        |> Integer.to_string
    end
  end

  @spec get_failed_downloads() :: [t]
  def get_failed_downloads do
    Brando.repo.all(
      from m in __MODULE__,
        where: m.status == 3
    )
  end

  def get_20_latest do
    Brando.repo.all(
      from m in __MODULE__,
          select: m.instagram_id,
        order_by: [desc: m.created_time],
           limit: 20
    )
  end

  @doc """
  Get min_id from where we search for new images
  """
  @spec get_min_id() :: :blank | String.t
  def get_min_id do
    id = Brando.repo.one(
      from m in __MODULE__,
        select: m.instagram_id,
        order_by: [desc: m.instagram_id],
        limit: 1
    )

    case id do
      nil -> :blank
      id -> Enum.at(String.split(id, "_"), 0)
    end
  end

  #
  # Meta

  use Brando.Meta.Schema, [
    singular: gettext("instagram image"),
    plural: gettext("instagram images"),
    repr: &("#{&1.id} | #{&1.caption}"),
    fields: [
      id: gettext("ID"),
      instagram_id: gettext("Instagram ID"),
      type: gettext("Type"),
      caption: gettext("Caption"),
      link: gettext("Link"),
      url_original: gettext("Image URL"),
      url_thumbnail: gettext("Thumbnail URL"),
      created_time: gettext("Created"),
      status: gettext("Status"),
    ]
  ]
end
