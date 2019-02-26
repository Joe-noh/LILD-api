defmodule LILDWeb.UserControllerTest do
  use LILDWeb.ConnCase

  import Mock
  alias LILD.Accounts

  @firebase_response Fixture.Accounts.firebase_id_token_payload()

  setup %{conn: conn} do
    %{conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test_with_mock "renders user when data is valid", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      params = Fixture.Accounts.user(%{id_token: "firebase.id_token"})

      data =
        post(conn, Routes.user_path(conn, :create), user: params)
        |> json_response(201)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["name"] == params[:name]
      assert data["avatar_url"] == params[:avatar_url]
    end

    test_with_mock "renders errors when data is invalid", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      errors =
        post(conn, Routes.user_path(conn, :create), user: %{})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "update user" do
    setup [:create_user, :login]

    test "renders user when data is valid", %{conn: conn, user: user} do
      params = Fixture.Accounts.user()

      data =
        put(conn, Routes.user_path(conn, :update, user), user: params)
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["name"] == params[:name]
      assert data["avatar_url"] == params[:avatar_url]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      errors =
        put(conn, Routes.user_path(conn, :update, user), user: %{name: ''})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "401 when not logged in", %{conn: conn, user: user} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> put(Routes.user_path(conn, :update, user))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "delete user" do
    setup [:create_user, :login]

    test "deletes chosen user", %{conn: conn, user: user} do
      assert delete(conn, Routes.user_path(conn, :delete, user)) |> response(204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end

    test "401 when not logged in", %{conn: conn, user: user} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> delete(Routes.user_path(conn, :delete, user))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
  end

  defp login(%{conn: conn, user: user}) do
    %{conn: Plug.Conn.assign(conn, :current_user, user)}
  end
end
