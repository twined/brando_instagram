defmodule Brando.Instagram.Admin.InstagramController do
  @moduledoc """
  Controller for the Instagram module.
  """

  use Brando.Web, :controller
  alias Brando.InstagramImage
  import Brando.Instagram.Gettext
  import Brando.Plug.HTML
  import Ecto.Query

  plug :put_section, "instagram"

  @doc """
  Renders the main index.
  """
  def index(conn, _params) do
    images = Brando.repo.all(
      from i in InstagramImage,
        select: %{
          id: i.id,
          status: i.status,
          image: i.image,
          created_time: i.created_time
        },
        order_by: [
          desc: i.status,
          desc: i.created_time
        ]
    )

    conn
    |> assign(:page_title, gettext("Index - Instagram"))
    |> assign(:images, images)
    |> render
  end

  def change_status(conn, %{"ids" => ids, "status" => status}) do
    Brando.repo.update_all(
      from(i in InstagramImage,
        where: i.id in ^ids
      ),
      set: [status: status]
    )

    json(conn, %{status: "200", ids: ids, new_status: status})
  end
end
