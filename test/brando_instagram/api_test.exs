defmodule Brando.Instagram.APITest do
  use ExUnit.Case, async: false
  use BrandoInstagram.ConnCase
  alias Brando.Instagram.API
  alias Brando.InstagramImage

  @instaimage %{
    "approved" => true,
    "caption" => "",
    "created_time" => "1412585304",
    "deleted" => false,
    "id" => 3261,
    "instagram_id" => "968134024444958851_000000",
    "username" => "username",
    "link" => "https://instagram.com/p/fakelink/",
    "type" => "image",
    "url_original" => "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
    "url_thumbnail" => "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/s150x150/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2"}

  test "get_user_id" do
    assert API.get_user_id("dummy_user", state()) == {:ok, "0123456"}
  end

  test "get images for user" do
    Brando.repo.delete_all(InstagramImage)
    assert API.images_for_user("dummy_user", state(), min_id: "968134024444958851")
           == :ok
    assert length(Brando.repo.all(InstagramImage)) == 2
  end

  test "get images for tags" do
    Brando.repo.delete_all(InstagramImage)
      assert API.images_for_tags(["haraball"], state(), min_id: "968134024444958851")
             == :ok
      assert length(Brando.repo.all(InstagramImage)) == 1
  end

  test "query user" do
    # dump images
    Brando.repo.delete_all(InstagramImage)
    cfg = Application.get_env(:brando, Brando.Instagram)
    cfg = Keyword.put(cfg, :query, {:user, "dummy_user"})
    Application.put_env(:brando, Brando.Instagram, cfg)
    # install fake image in db
    {:ok, _} = InstagramImage.create(@instaimage)

    assert API.query(state(:blank, cfg[:query])) == {:ok, "970249962242331087"}
    assert API.query(state("1412585305", cfg[:query])) == {:ok, "970249962242331087"}
  end

  test "query tag" do
    # dump images
    Brando.repo.delete_all(InstagramImage)
    cfg = Application.get_env(:brando, Brando.Instagram)
    cfg = Keyword.put(cfg, :query, {:tags, ["haraball"]})
    Application.put_env(:brando, Brando.Instagram, cfg)

    # install fake image in db
    {:ok, _} = InstagramImage.create(@instaimage)
    assert API.query(state(:blank, cfg[:query]))
           == {:ok, "970249962242331087"}
    assert API.query(state("968134024444958851", cfg[:query]))
           == {:ok, "970249962242331087"}
  end

  test "client_id error" do
    assert API.get_user_id("asf98293h8a9283fh9a238fh", state())
           == {:error, "Instagram API 400 error: \"The client_id " <>
                       "provided is invalid and does not match a valid " <>
                       "application.\""}
  end

  test "user not found" do
    assert API.get_user_id("djasf98293h8a9283fh9a238fh", state())
           == {:error, "User not found: djasf98293h8a9283fh9a238fh"}
  end

  test "process_response_body" do
    assert API.process_response_body(~s({"test": "one", "test": "two"}))
           == [test: "one"]
    assert API.process_response_body(<<132,142>>)
           == <<132,142>>
  end

  defp state(filter \\ :blank, query \\ nil) do
    %Brando.Instagram.Server.State{filter: filter, query: query, access_token: "DUMMY_TOKEN"}
  end
end
