defmodule BrandoInstagram.Factory do
  use ExMachina.Ecto, repo: Brando.repo

  alias Brando.InstagramImage

  def factory(:instagram_image) do
    %InstagramImage{
      caption: "Image caption",
      created_time: "1412469138",
      instagram_id: "000000000000000000_000000",
      link: "https://instagram.com/p/dummy_link/",
      status: :approved,
      type: "image",
      url_original: "https://scontent.cdninstagram.com/0.jpg",
      url_thumbnail: "https://scontent.cdninstagram.com/0.jpg",
      username: "dummyuser"
    }
  end

  def factory(:instagram_image_params) do
    %{
      "caption" => "Image caption",
      "created_time" => "1412469138",
      "instagram_id" => "000000000000000000_000000",
      "link" => "https://instagram.com/p/dummy_link/",
      "type" => "image",
      "url_original" => "https://scontent.cdninstagram.com/0.jpg",
      "url_thumbnail" => "https://scontent.cdninstagram.com/0.jpg",
      "username" => "dummyuser"
    }
  end
end
