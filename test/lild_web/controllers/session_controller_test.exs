defmodule LILDWeb.SessionControllerTest do
  use LILDWeb.ConnCase, async: true

  import Mock
  alias LILD.Accounts

  describe "create" do
    setup [:create_user]

    test_with_mock "ログインする", %{conn: conn, user: user, provider: provider, uid: uid}, Accounts, [:passthrough],
      verify_id_token: fn _ -> {:ok, %{"provider" => provider, "uid" => uid}} end do
      json =
        post(conn, Routes.session_path(conn, :create), %{firebase: Fixture.Accounts.firebase()})
        |> json_response(201)

      assert json["user"]["id"] |> is_binary
      assert json["user"]["name"] == user.name
      assert json["user"]["avatar_url"] == user.avatar_url
      assert json["auth"]["token"] |> is_binary
    end

    test_with_mock "SocialAccountが見つからないときは401", %{conn: conn, provider: provider, uid: uid}, Accounts, [:passthrough],
      verify_id_token: fn _ -> {:ok, %{"provider" => provider, "uid" => uid <> "1"}} end do
      errors =
        post(conn, Routes.session_path(conn, :create), firebase: Fixture.Accounts.firebase())
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_user(_) do
    social_params = %{"provider" => provider, "uid" => uid} = Fixture.Accounts.social_account()
    {:ok, %{user: user}} = Accounts.create_user(Fixture.Accounts.user(), social_params)

    %{user: user, provider: provider, uid: uid}
  end
end
