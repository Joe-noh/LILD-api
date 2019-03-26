defmodule LILDWeb.SessionControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILDWeb.RefreshToken

  describe "update" do
    setup [:create_user]

    test "refresh tokenとaccess tokenを交換する", %{conn: conn, user: user} do
      {:ok, refresh_token, _payload} = RefreshToken.encode(user)
      json =
        put(conn, Routes.session_path(conn, :update), %{refresh_token: refresh_token})
        |> json_response(200)

      assert json["user"]["id"] |> is_binary
      assert json["user"]["name"] == user.name
      assert json["user"]["avatar_url"] == user.avatar_url
      assert json["auth"]["access_token"] |> is_binary
      assert json["auth"]["refresh_token"] |> is_binary
    end

    test "refresh tokenが期限切れの場合は401", %{conn: conn, user: user} do
      while_ago = DateTime.utc_now |> DateTime.add(-10, :second) |> DateTime.to_unix
      {:ok, refresh_token, _payload} = RefreshToken.generate_and_sign(%{"exp" => while_ago, "sub" => user.id})

      errors =
        put(conn, Routes.session_path(conn, :update), %{refresh_token: refresh_token})
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_user(_) do
    social_params = %{"provider" => provider, "uid" => uid} = Fixture.Accounts.social_account()
    {:ok, %{user: user}} = LILD.Accounts.create_user(Fixture.Accounts.user(), social_params)

    %{user: user, provider: provider, uid: uid}
  end
end
