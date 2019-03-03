defmodule LILDWeb.UserControllerTest do
  use LILDWeb.ConnCase, async: true

  import Mock
  alias LILD.{Accounts, Dreams}

  @firebase_response Fixture.Accounts.firebase_id_token_payload()

  describe "show" do
    setup [:create_users, :login_as_owner]

    test "レスポンスがAPIドキュメントと乖離していない", %{conn: conn, owner: owner} do
      get(conn, Routes.user_path(conn, :show, owner))
      |> json_response(200)
      |> assert_schema("UserResponse", LILDWeb.ApiSpec.spec())
    end
  end

  describe "create" do
    test_with_mock "レスポンスがAPIドキュメントと乖離していない", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      user_params = Fixture.Accounts.user()
      firebase_params = Fixture.Accounts.firebase()

      post(conn, Routes.user_path(conn, :create), user: user_params, firebase: firebase_params)
      |> json_response(201)
      |> assert_schema("SessionResponse", LILDWeb.ApiSpec.spec())
    end

    test_with_mock "ユーザを登録する", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      user_params = Fixture.Accounts.user()
      firebase_params = Fixture.Accounts.firebase()

      data =
        post(conn, Routes.user_path(conn, :create), user: user_params, firebase: firebase_params)
        |> json_response(201)
        |> Map.get("data")

      assert data["user"]["id"] |> is_binary
      assert data["user"]["name"] == user_params["name"]
      assert data["user"]["avatar_url"] == user_params["avatar_url"]
    end

    test_with_mock "パラメータがよくないときは422", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      errors =
        post(conn, Routes.user_path(conn, :create), user: %{}, firebase: Fixture.Accounts.firebase())
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "update" do
    setup [:create_users, :login_as_owner]

    test "レスポンスがAPIドキュメントと乖離していない", %{conn: conn, owner: owner} do
      params = Fixture.Accounts.user()

      put(conn, Routes.user_path(conn, :update, owner), user: params)
      |> json_response(200)
      |> assert_schema("UserResponse", LILDWeb.ApiSpec.spec())
    end

    test "ユーザを更新する", %{conn: conn, owner: owner} do
      params = Fixture.Accounts.user()

      data =
        put(conn, Routes.user_path(conn, :update, owner), user: params)
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["name"] == params["name"]
      assert data["avatar_url"] == params["avatar_url"]
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
    {:ok, %{user: owner}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())

    {:ok, _} = Dreams.create_dream(owner, Fixture.Dreams.dream())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end
end
