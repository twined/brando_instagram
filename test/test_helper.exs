Code.require_file("support/router_helper.exs", __DIR__)
Code.require_file("support/instagram_helper.exs", __DIR__)

{:ok, _} = Application.ensure_all_started(:brando)
{:ok, _} = Application.ensure_all_started(:ecto)
{:ok, _} = Application.ensure_all_started(:ex_machina)

Brando.Registry.wipe()
Brando.Registry.register(Brando.Instagram)

ExUnit.start()

defmodule BrandoInstagram.Integration.TestRepo do
  use Ecto.Repo, otp_app: :brando_instagram
end

defmodule BrandoInstagram.Integration.Endpoint do
  use Phoenix.Endpoint,
    otp_app: :brando_instagram

  plug Plug.Session,
    store: :cookie,
    key: "_test",
    signing_salt: "signingsalt"

  plug Plug.Static,
    at: "/", from: :brando_pages, gzip: false,
    only: ~w(css images js fonts favicon.ico robots.txt),
    cache_control_for_vsn_requests: nil,
    cache_control_for_etags: nil
end

Mix.Task.run "ecto.create", ["-r", BrandoInstagram.Integration.TestRepo, "--quiet"]
Mix.Task.run "ecto.migrate", ["-r", BrandoInstagram.Integration.TestRepo, "--quiet"]

BrandoInstagram.Integration.TestRepo.start_link()

Ecto.Adapters.SQL.Sandbox.mode(BrandoInstagram.Integration.TestRepo, :manual)
Brando.endpoint.start_link
