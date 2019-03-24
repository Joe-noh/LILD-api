defmodule LILDWeb.UserControllerTest do
  use LILDWeb.ConnCase, async: false

  import Mock
  alias LILD.{Accounts, Dreams}

  @firebase_response Fixture.Accounts.firebase_id_token_payload()

  describe "create" do
    test_with_mock "ユーザを登録する", %{conn: conn}, Jwt, [:passthrough], verify: fn _ -> {:ok, @firebase_response} end do
      json =
        post(conn, Routes.user_path(conn, :create), Fixture.Accounts.firebase())
        |> json_response(201)

      assert json["user"]["id"] |> is_binary
      assert json["user"]["name"] == @firebase_response["name"]
      assert json["user"]["avatar_url"] == @firebase_response["picture"]
      assert json["auth"]["access_token"] |> is_binary
      assert json["auth"]["refresh_token"] |> is_binary
    end

    test_with_mock "ユーザが存在する場合はそれを返す", %{conn: conn}, Jwt, [:passthrough], verify: fn _ -> {:ok, @firebase_response} end do
      _json = post(conn, Routes.user_path(conn, :create), Fixture.Accounts.firebase()) |> json_response(201)
      json = post(conn, Routes.user_path(conn, :create), Fixture.Accounts.firebase()) |> json_response(201)

      assert json["user"]["id"] |> is_binary
      assert json["user"]["name"] == @firebase_response["name"]
      assert json["user"]["avatar_url"] == @firebase_response["picture"]
      assert json["auth"]["access_token"] |> is_binary
      assert json["auth"]["refresh_token"] |> is_binary
    end
  end

  describe "update" do
    setup [:create_users, :login_as_owner]

    test "ユーザを更新する", %{conn: conn, owner: owner} do
      params = Fixture.Accounts.user()

      json =
        put(conn, Routes.user_path(conn, :update, owner), user: params)
        |> json_response(200)
        |> Map.get("user")

      assert json["id"] |> is_binary
      assert json["name"] == params["name"]
      assert json["avatar_url"] == params["avatar_url"]
    end

    test "パラメータがよくないときは422", %{conn: conn, owner: owner} do
      errors =
        put(conn, Routes.user_path(conn, :update, owner), user: %{name: ''})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "ログインしてないときは401", %{conn: conn, owner: owner} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> put(Routes.user_path(conn, :update, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "他人のことは更新できない", %{conn: conn, owner: owner, another: another} do
      errors =
        Plug.Conn.assign(conn, :current_user, another)
        |> put(Routes.user_path(conn, :update, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "delete" do
    setup [:create_users, :login_as_owner]

    test "ユーザを削除する", %{conn: conn, owner: owner} do
      assert delete(conn, Routes.user_path(conn, :delete, owner)) |> response(204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, owner))
      end
    end

    test "ログインしてないときは401", %{conn: conn, owner: owner} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> delete(Routes.user_path(conn, :delete, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "他人のことは消せない", %{conn: conn, owner: owner, another: another} do
      errors =
        Plug.Conn.assign(conn, :current_user, another)
        |> delete(Routes.user_path(conn, :delete, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_users(_) do
    {:ok, %{user: owner}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    {:ok, _} = Dreams.create_dream(owner, Fixture.Dreams.dream())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end
end
