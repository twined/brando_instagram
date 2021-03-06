defmodule Brando.Integration.InstagramImageTest do
  use ExUnit.Case
  use BrandoInstagram.ConnCase
  alias Brando.InstagramImage
  alias BrandoInstagram.Factory

  test "create/1 and update/1" do
    img = Factory.insert(:instagram_image)
    assert {:ok, updated_img} = InstagramImage.update(img, %{"caption" => "New caption"})
    assert updated_img.caption == "New caption"
  end

  test "create/1 errors" do
    {_v, params} = Dict.pop(Factory.params_for(:instagram_image), :link)
    assert {:error, changeset} = InstagramImage.create(params)
    assert changeset.errors == [link: {"can't be blank", []}]
  end

  test "get/1" do
    img = Factory.insert(:instagram_image)
    assert Brando.repo.get_by!(InstagramImage, id: img.id) == img
  end

  test "changeset" do
    cs = InstagramImage.changeset(%InstagramImage{status: :download_failed}, :update, %{"image" => %{}})
    assert Map.get(cs.changes, :status) == :approved
    cs = InstagramImage.changeset(%InstagramImage{status: :download_failed}, :update, %{"image" => nil})
    assert Map.get(cs.changes, :status) == nil
  end

  test "update" do
    result = InstagramImage.update(%InstagramImage{status: :download_failed}, %{"created_time" => 1})
    assert result == {:error, [created_time: {"is invalid", [type: :string]}]}
  end

  test "meta" do
    assert InstagramImage.__repr__(%{id: 5, caption: "Caption"}) == "5 | Caption"
    assert Brando.InstagramImage.__name__(:singular) == "instagram image"
    assert Brando.InstagramImage.__name__(:plural) == "instagram images"
  end
end
