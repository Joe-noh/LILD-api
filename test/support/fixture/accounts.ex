defmodule LILD.Fixture.Accounts do
  def user(attrs \\ %{}) do
    LILD.Fixture.merge(attrs, %{
      "name" => Ffaker.En.Internet.user_name(),
      "avatar_url" => Ffaker.En.Internet.uri()
    })
  end

  def social_account(attrs \\ %{}) do
    LILD.Fixture.merge(attrs, %{
      "uid" => random_uid(),
      "provider" => Enum.random(["twitter.com", "google.com"])
    })
  end

  def firebase(attrs \\ %{}) do
    LILD.Fixture.merge(attrs, %{
      "id_token" => "firebase.id.token"
    })
  end

  def firebase_id_token_payload do
    %{
      "aud" => "lild-dev",
      "auth_time" => 1_550_966_987,
      "exp" => 1_550_970_587,
      "firebase" => %{
        "identities" => %{"twitter.com" => [random_uid()]},
        "sign_in_provider" => "twitter.com"
      },
      "iat" => 1_550_966_987,
      "iss" => "https://securetoken.google.com/lild-dev",
      "name" => "paintgraphics",
      "picture" => "https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png",
      "sub" => "tR7hx0eEqeZYYOM9mODVmM39TUP2",
      "user_id" => "tR7hx0eEqeZYYOM9mODVmM39TUP2"
    }
  end

  defp random_uid do
    Enum.random(1..999_999_999_999_999_999) |> Integer.to_string()
  end
end
