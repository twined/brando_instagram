defmodule Brando.Instagram.Routes.Admin do
  @moduledoc """
  Routes for Brando's Instagram module

  ## Usage:

  In `router.ex`

      scope "/admin", as: :admin do
        pipe_through :admin
        instagram_routes "/"

  """

  defmacro instagram_routes(path, opts \\ []), do:
    add_resources(path, opts)

  defp add_resources(path, opts) do
    quote do
      ctrl = Brando.Instagram.Admin.InstagramController

      path = unquote(path)
      opts = unquote(opts)

      get  "#{path}",               ctrl, :index,   opts
      post "#{path}/change-status", ctrl, :change_status, opts
    end
  end
end
