defmodule LILDWeb.PresignControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.Accounts

  setup [:create_user, :login_as_user]

  describe "create" do
    test "S3へのアップロードに必要な情報を返す", %{conn: conn} do
      json =
        post(conn, Routes.presign_path(conn, :create, %{mimetype: "image/jpeg"}))
        |> json_response(201)
        |> Map.get("presign")

      assert json["url"] == "https://lild-dev.s3.amazonaws.com/"
      assert json["fields"] |> is_map()
    end

    test "ログインしてないときは401", %{conn: conn} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> post(Routes.presign_path(conn, :create, %{mimetype: "image/jpeg"}))
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
