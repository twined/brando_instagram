defmodule Brando.Instagram.APITest do
  use ExUnit.Case, async: false
  use BrandoInstagram.ConnCase
  alias Brando.Instagram.API
  alias Brando.InstagramImage

  @instaimage %{
    approved: true,
    caption: "",
    created_time: "1412585304",
    deleted: false,
    id: 3261,
    instagram_id: "968134024444958851_000000",
    image: nil,
    username: "username",
    link: "https://instagram.com/p/fakelink/",
    type: "image",
    url_original: "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
    url_thumbnail: "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/s150x150/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2"
  }

  test "get images for user" do
    Brando.repo.delete_all(InstagramImage)
    assert API.images_for_user("dummy_user")
           == :ok
    assert length(Brando.repo.all(InstagramImage)) == 12
  end

  test "get images for tags" do
    Brando.repo.delete_all(InstagramImage)
      assert API.images_for_tag("haraball") == :ok
      assert length(Brando.repo.all(InstagramImage)) == 66
  end

  test "query user" do
    # dump images
    Brando.repo.delete_all(InstagramImage)
    cfg = Application.get_env(:brando, Brando.Instagram)
    cfg = Keyword.put(cfg, :query, {:user, "dummy_user"})
    Application.put_env(:brando, Brando.Instagram, cfg)
    # install fake image in db
    {:ok, _} = InstagramImage.create(@instaimage)

    assert API.query(state(cfg[:query])) == :ok
  end

  test "query tag" do
    # dump images
    Brando.repo.delete_all(InstagramImage)
    cfg = Application.get_env(:brando, Brando.Instagram)
    cfg = Keyword.put(cfg, :query, {:tag, "haraball"})
    Application.put_env(:brando, Brando.Instagram, cfg)

    # install fake image in db
    {:ok, _} = InstagramImage.create(@instaimage)
    assert API.query(state(cfg[:query])) == :ok
  end

  defp state(query) do
    %Brando.Instagram.Server.State{query: query}
  end
end
