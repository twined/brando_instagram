defmodule Brando.Integration.Instagram do
  @img_fixture "#{Path.expand("..", __DIR__)}/fixtures/sample.jpg"
  @user_fixture File.read!("#{Path.expand("..", __DIR__)}/fixtures/user.html")
  @tag_fixture File.read!("#{Path.expand("..", __DIR__)}/fixtures/tag.html")

  # Media
  def get("https://www.instagram.com/dummy_user/") do
    {
      :ok,
      %{
        body: @user_fixture,
        headers: [],
        status_code: 200
      }
    }
  end

  # Media for users
  def get("https://www.instagram.com/explore/tags/haraball/") do
    {
      :ok,
      %{
        body: @tag_fixture,
        headers: [],
        status_code: 200
      }
    }
  end

  def get("https://api.instagram.com/v1/users/0123456/media/recent/?access_token=DUMMY_TOKEN&min_id=" <> _ts) do
    {
      :ok,
      %{
        body: [
          data: [
            %{
              "caption" => nil,
              "created_time" => "1426980419",
              "id" => "000000000000000000_000000",
              "images" => %{
                "standard_resolution" => %{
                  "height" => 640,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/e15/1.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 640
                },
                "thumbnail" => %{
                  "height" => 150,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/s150x150/e15/1.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 150
                }
              },
              "link" => "https://instagram.com/p/0/",
              "type" => "image",
              "user" => %{
                "full_name" => "",
                "id" => "012345",
                "profile_picture" => "",
                "username" => "dummy_user"
              },
            },
            %{
              "caption" => nil,
              "created_time" => "1412585305",
              "id" => "1111111111111_0123456",
              "images" => %{
                "standard_resolution" => %{
                  "height" => 640,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xpf1/t51.2885-15/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 640
                },
                "thumbnail" => %{
                  "height" => 150,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xpf1/t51.2885-15/s150x150/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 150
                }
              },
              "link" => "https://instagram.com/p/1/",
              "type" => "image",
              "user" => %{
                "full_name" => "",
                "id" => "0123456",
                "profile_picture" => "",
                "username" => "dummy_user"
              },
              "users_in_photo" => []
            }
          ],
          meta: %{
            "code" => 200
          },
          pagination: %{}
        ],
        headers: [],
        status_code: 200
      }
    }
  end

  def get("https://api.instagram.com/v1/users/0123456/media/recent/?access_token=DUMMY_TOKEN&min_id=968134024444958851") do
    {
      :ok,
      %{
        body: [
          data: [
            %{
              "caption" => nil,
              "created_time" => "1426980419",
              "id" => "000000000000000000_000000",
              "images" => %{
                "standard_resolution" => %{
                  "height" => 640,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/e15/1.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 640
                },
                "thumbnail" => %{
                  "height" => 150,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xft1/t51.2885-15/s150x150/e15/1.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 150
                }
              },
              "link" => "https://instagram.com/p/0/",
              "type" => "image",
              "user" => %{
                "full_name" => "",
                "id" => "012345",
                "profile_picture" => "",
                "username" => "dummy_user"
              },
            },
            %{
              "caption" => nil,
              "created_time" => "1412585305",
              "id" => "1111111111111_0123456",
              "images" => %{
                "standard_resolution" => %{
                  "height" => 640,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xpf1/t51.2885-15/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 640
                },
                "thumbnail" => %{
                  "height" => 150,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xpf1/t51.2885-15/s150x150/e15/0.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 150
                }
              },
              "link" => "https://instagram.com/p/1/",
              "type" => "image",
              "user" => %{
                "full_name" => "",
                "id" => "0123456",
                "profile_picture" => "",
                "username" => "dummy_user"
              },
            }
          ],
          meta: %{"code" => 200},
          pagination: %{}
        ],
        headers: [],
        status_code: 200
      }
    }
  end

  # Media for tags
  def get("https://api.instagram.com/v1/tags/haraball/media/recent?access_token=DUMMY_TOKEN&min_tag_id=0") do
    {
      :ok,
      %{
        body: [
          data: [
            %{
              "caption" => %{
                "created_time" => "1429882830",
                "id" => "970249963802612652",
                "text" => "Caption here. #test"
              },
              "created_time" => "1429882830",
              "id" => "970249962242331087_1492879755",
              "images" => %{
                "standard_resolution" => %{
                  "height" => 640,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xap1/t51.2885-15/e15/11190180_464905646995552_1163060820_n.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 640
                },
                "thumbnail" => %{
                  "height" => 150,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xap1/t51.2885-15/s150x150/e15/11190180_464905646995552_1163060820_n.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 150
                }
              },
              "link" => "https://instagram.com/p/13BTM2ylHP/",
              "type" => "image",
              "user" => %{
                "full_name" => "HARABALL",
                "id" => "1492879755",
                "profile_picture" => "",
                "username" => "haraball_"
              },
            }
          ],
          meta: %{"code" => 200},
          pagination: %{
            "min_tag_id" => "974770073844008277",
            "next_min_id" => "974770073844008277"
          }
        ],
        headers: [],
        status_code: 200
      }
    }
  end

  def get("https://api.instagram.com/v1/tags/haraball/media/recent?access_token=DUMMY_TOKEN&min_tag_id=" <> _) do
    {
      :ok,
      %{
        body: [
          data: [
            %{
              "attribution" => nil,
              "caption" => %{
                "created_time" => "1429882830",
                "id" => "970249963802612652",
                "text" => "Caption text."
              },
              "created_time" => "1429882830",
              "id" => "970249962242331087_1492879755",
              "images" => %{
                "standard_resolution" => %{
                  "height" => 640,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xap1/t51.2885-15/e15/11190180_464905646995552_1163060820_n.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 640
                },
                "thumbnail" => %{
                  "height" => 150,
                  "url" => "https://scontent.cdninstagram.com/hphotos-xap1/t51.2885-15/s150x150/e15/11190180_464905646995552_1163060820_n.jpg?ig_cache_key=MTAzMjQ4MDk5NjcxNjMwODc5OA==.2",
                  "width" => 150
                }
              },
              "link" => "https://instagram.com/p/13BTM2ylHP/",
              "type" => "image",
              "user" => %{
                "full_name" => "HARABALL",
                "id" => "1492879755",
                "profile_picture" => "",
                "username" => "haraball_"
              },
            }
          ],
          meta: %{"code" => 200},
          pagination: %{
            "min_tag_id" => "974770073844008277",
            "next_min_id" => "974770073844008277"
          }
        ],
        headers: [],
        status_code: 200
      }
    }
  end

  # Mock image
  def get(_) do
    body = File.read!(@img_fixture)
    {:ok, %{body: body, status_code: 200}}
  end
end
