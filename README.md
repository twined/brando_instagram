# Brando Instagram

[![Coverage Status](https://coveralls.io/repos/github/twined/brando_instagram/badge.svg?branch=master)](https://coveralls.io/github/twined/brando_instagram?branch=master)

## Installation

Add brando_instagram to your list of dependencies in `mix.exs`:

```diff
    def deps do
      [
        {:brando, github: "twined/brando"},
+       {:brando_instagram, github: "twined/brando_instagram", branch: "develop"}
      ]
    end
```

Install migrations and frontend files:

    $ mix brando_instagram.install

Run migrations

    $ mix ecto.migrate

Add to your `lib/my_app.ex`:

```diff
    def start(_type, _args) do
      import Supervisor.Spec, warn: false

      children = [
        # Start the endpoint when the application starts
        supervisor(MyApp.Endpoint, []),
        # Start the Ecto repository
        supervisor(MyApp.Repo, []),
+       # Start the Instagram supervisor
+       worker(Brando.Instagram, []),
        # Here you could define other workers and supervisors as children
        # worker(MyApp.Worker, [arg1, arg2, arg3]),
      ]

+     Brando.Registry.register(Brando.Instagram)
```

## Configuration options

These are the options for `config :brando, Brando.Instagram`:

  * `interval`: How often we poll for new images
  * `auto_approve`: Set `approved` to `true` on grabbed images.
  * `query`: What to query.
    * `{:user, "your_name"}` - polls for `your_name`'s images.
    * `{:tag, "tag1"}` - polls for `tag1`

Default config:

```elixir
config :brando, Brando.Instagram,
  auto_approve: true,
  query: {:user, "username"},
  interval: 1_000 * 60 * 60,
  sleep: 5528,
  sizes: %{
    "large" =>  %{"size" => "640", "quality" => 80},
    "largecrop" =>  %{"size" => "640x640", "quality" => 80, "crop" => true},
    "thumb" =>  %{"size" => "150x150", "quality" => 70, "crop" => true}
  },
  upload_path: Path.join("images", "instagram")
```
