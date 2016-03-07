use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :brando_instagram, BrandoInstagram.Integration.Endpoint,
  http: [port: 4001],
  server: false,
  secret_key_base: "verysecret"

config :logger, level: :warn

config :brando_instagram, BrandoInstagram.Integration.TestRepo,
  url: "ecto://postgres:postgres@localhost/brando_instagram_test",
  adapter: Ecto.Adapters.Postgres,
  extensions: [{Postgrex.Extensions.JSON, library: Poison}],
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_overflow: 0

config :brando, :otp_app, :brando_instagram

config :brando, :router, BrandoInstagram.Router
config :brando, :endpoint, BrandoInstagram.Integration.Endpoint
config :brando, :repo, BrandoInstagram.Integration.TestRepo
config :brando, :helpers, BrandoInstagram.Router.Helpers

config :brando, :media_url, "/media"
config :brando, :media_path, Path.join([Mix.Project.app_path, "tmp", "media"])

config :brando, Brando.Villain, parser: Brando.Villain.Parser.Default
config :brando, Brando.Villain, extra_blocks: []

config :brando, :default_language, "en"
config :brando, :admin_default_language, "en"
config :brando, :languages, [
  [value: "nb", text: "Norsk"],
  [value: "en", text: "English"]
]
config :brando, :admin_languages, [
  [value: "nb", text: "Norsk"],
  [value: "en", text: "English"]
]

config :brando, Brando.Images, [
  default_config: %{
    allowed_mimetypes: ["image/jpeg", "image/png"],
    default_size: :medium, size_limit: 10240000,
    upload_path: Path.join("images", "default"),
    sizes: %{
      "small" =>  %{"size" => "300", "quality" => 100},
      "medium" => %{"size" => "500", "quality" => 100},
      "large" =>  %{"size" => "700", "quality" => 100},
      "xlarge" => %{"size" => "900", "quality" => 100},
      "thumb" =>  %{"size" => "150x150", "quality" => 100, "crop" => true},
      "micro" =>  %{"size" => "25x25", "quality" => 100, "crop" => true}
    }
  },
  optimize: [
    png: [
      bin: "cp",
      args: "%{filename} %{new_filename}"
    ]
  ]
]

config :brando, Brando.Instagram,
  auto_approve: true,
  client_id: "CLIENT_ID",
  username: "username",
  password: "password",
  token_path: Path.join(~w(tmp priv tokens instagram)),
  api_http_lib: Brando.Integration.Instagram,
  token_http_lib: Brando.Integration.Instagram,
  interval: 1_000 * 60 * 60,
  sizes: %{
    "large" => %{"size" => "640", "quality" => 100},
    "thumb" => %{"size" => "150x150", "quality" => 100, "crop" => true}
  },
  sleep: 0,
  query: {:user, "dummy_user"},
  upload_path: Path.join("images", "insta")

config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1
