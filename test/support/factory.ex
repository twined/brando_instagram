defmodule BrandoInstagram.Factory do
  use ExMachina.Ecto, repo: Brando.repo

  alias Brando.InstagramImage

  def instagram_image_factory do
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
end
