defmodule LILDWeb.SignatureControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.Accounts

  setup [:create_user, :login_as_user]

  describe "create" do
    test "署名を返す", %{conn: conn, user: user} do
      json =
        post(conn, Routes.signature_path(conn, :create, %{mimetype: "image/jpeg"}))
        |> json_response(201)
        |> Map.get("signature")

      assert json["Content-Type"] == "image/jpeg"
      assert json["key"] =~ Regex.compile!("^avatars/#{user.id}/[A-Z0-9]+.jpg$")
    end

    test "ログインしてないときは401", %{conn: conn} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> post(Routes.signature_path(conn, :create, %{mimetype: "image/jpeg"}))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
  end

  defp login_as_user(%{conn: conn, user: user}) do
    %{conn: Plug.Conn.assign(conn, :current_user, user)}
  end
end
