defmodule BrandoInstagram.RoutesTest do
  use ExUnit.Case

  setup do
    routes =
      Phoenix.Router.ConsoleFormatter.format(Brando.router)
    {:ok, [routes: routes]}
  end

  test "instagram_routes", %{routes: routes} do
    assert routes =~ "/admin/instagram"
    assert routes =~ "/admin/instagram/change-status"
  end
end
