defmodule LILDWeb.UserControllerTest do
  use LILDWeb.ConnCase

  import Mock

  alias LILD.Accounts
  alias LILD.Accounts.User

  @invalid_attrs %{avatar_url: nil, name: nil, id_token: nil}

  @firebase_response Fixture.Accounts.firebase_id_token_payload

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test_with_mock "renders user when data is valid", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      params = Fixture.Accounts.user(%{id_token: "firebase.id_token"})
      data = conn
        |> post(Routes.user_path(conn, :create), user: params)
        |> json_response(201)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["name"] == params[:name]
      assert data["avatar_url"] == params[:avatar_url]
    end

    test_with_mock "renders errors when data is invalid", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: user} do
      params = Fixture.Accounts.user
      data = conn
        |> put(Routes.user_path(conn, :update, user), user: params)
        |> json_response(200)

      assert data["id"] |> is_binary
      assert data["name"] == params[:name]
      assert data["avatar_url"] == params[:avatar_url]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user, Fixture.Accounts.firebase_account)
  end
end
