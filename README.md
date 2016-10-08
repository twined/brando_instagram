# Brando Instagram

[![Coverage Status](https://coveralls.io/repos/github/twined/brando_instagram/badge.svg?branch=master)](https://coveralls.io/github/twined/brando_instagram?branch=master)

## Installation

Add brando_instagram to your list of dependencies in `mix.exs`:

```diff
    def deps do
      [
        {:brando, github: "twined/brando"},
+       {:brando_instagram, github: "twined/brando_instagram"}
      ]
    end
```

Install migrations and frontend files:

    $ mix brando_instagram.install

Run migrations

    $ mix ecto.migrate

Add to your `web/router.ex`:

```diff

    defmodule MyApp.Router do
      use MyApp.Web, :router
      # ...
+     import Brando.Instagram.Routes.Admin

      scope "/admin", as: :admin do
        pipe_through :admin
        dashboard_routes   "/"
        user_routes        "/users"
+       instagram_routes   "/instagram"
      end
    end
```

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

Add to your `web/static/css/app.scss`:

```diff
  @import "includes/colorbox";
  @import "includes/cookielaw";
  @import "includes/dropdown";
  @import "includes/nav";
+ @import "includes/instagram";
```

Add to your `web/static/css/custom/brando.custom.scss`

```diff
+ @import
+   "includes/instagram"
```

`instagram.js` is copied to your `web/static/js/admin` directory, and needs to be initialized.

Edit `js/admin/custom.js`:

```javascript
'use strict';

import $ from 'jquery';
import Instagram from './instagram';

$(() => {
  switch ($('body').attr('data-script')) {
    case 'instagram-index':
      Instagram.setup();
    break;
  }
});
```

## Instagram setup

  * Login to your developer account.
  * Click "Manage Clients"
  * Click "Register a New Client"
  * Fill out form, add "http://localhost" to "Valid redirect URIs"
  * Click the security pane
  * Disable the "Disable implicit OAuth" choice

  * Click "Manage" on your newly created client
  * Click the "Sandbox"-pane
  * Add the account name of the Instagram account you want to track

  * Login to the developer section of the Instagram account you want to track
  * Click "Sandbox Invites"-tab at the top
  * Fill in information, if needed
  * Accept sandbox invitation from your dev account

## Configuration options

These are the options for `config :brando, Brando.Instagram`:

  * `client_id`: Your instagram client id. Find this in the developer section.
  * `use_token`: Use access_token instead of client_id for API calls.
  * `username`: Your instagram username. Needed for access_token retrieval.
  * `password`: Your instagram password. Needed for access_token retrieval.
  * `token_file`: Where to store your access_token.
  * `interval`: How often we poll for new images
  * `auto_approve`: Set `approved` to `true` on grabbed images.
  * `query`: What to query.
    * `{:user, "your_name"}` - polls for `your_name`'s images.
    * `{:tags, ["tag1", "tag2"]}` - polls `tag1` and `tag2`

Default config:

```elixir
config :brando, Brando.Instagram,
  auto_approve: true,
  client_id: "",
  username: "",
  password: "",
  query: {:user, "dummy_username"},
  token_path: Path.join(~w(priv tokens instagram)),
  interval: 1_000 * 60 * 60,
  sleep: 5000,
  sizes: %{
    "large" =>  %{"size" => "640", "quality" => 100},
    "thumb" =>  %{"size" => "150x150", "quality" => 100, "crop" => true}
  },
  upload_path: Path.join("images", "instagram")
```
