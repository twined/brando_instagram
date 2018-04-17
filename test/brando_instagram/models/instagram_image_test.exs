defmodule Brando.Integration.InstagramImageTest do
  use ExUnit.Case
  use BrandoInstagram.ConnCase
  alias Brando.InstagramImage

  test "changeset" do
    cs = InstagramImage.changeset(%InstagramImage{status: :download_failed}, :update, %{image: %{}})
    assert Map.get(cs.changes, :status) == :approved
    cs = InstagramImage.changeset(%InstagramImage{status: :download_failed}, :update, %{image: nil})
    assert Map.get(cs.changes, :status) == nil
  end

  test "meta" do
    assert InstagramImage.__repr__(%{id: 5, caption: "Caption"}) == "5 | Caption"
    assert Brando.InstagramImage.__name__(:singular) == "instagram image"
    assert Brando.InstagramImage.__name__(:plural) == "instagram images"
  end
end
