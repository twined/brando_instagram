defmodule Brando.Instagram.AccessTokenTest do
  use ExUnit.Case, async: false
  use BrandoInstagram.ConnCase
  alias Brando.Instagram.AccessToken

  @token_path Path.join([Mix.Project.app_path, "tmp", "priv",
                        "tokens", "instagram", "token.json"])

  setup do
    File.rm_rf!(@token_path)
    :ok
  end

  test "retrieve_token" do
    assert AccessToken.load_token == "abcd123"
    assert AccessToken.load_token == "abcd123"
  end
end
