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
    setup [:create_users, :login_as_owner]

    test "renders user when data is valid", %{conn: conn, owner: owner} do
      params = Fixture.Accounts.user()

      data =
        put(conn, Routes.user_path(conn, :update, owner), user: params)
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["name"] == params[:name]
      assert data["avatar_url"] == params[:avatar_url]
    end

    test "renders errors when data is invalid", %{conn: conn, owner: owner} do
      errors =
        put(conn, Routes.user_path(conn, :update, owner), user: %{name: ''})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "401 when not logged in", %{conn: conn, owner: owner} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> put(Routes.user_path(conn, :update, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "401 for another users", %{conn: conn, owner: owner, another: another} do
      errors =
        Plug.Conn.assign(conn, :current_user, another)
        |> put(Routes.user_path(conn, :update, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "delete user" do
    setup [:create_users, :login_as_owner]

    test "deletes chosen user", %{conn: conn, owner: owner} do
      assert delete(conn, Routes.user_path(conn, :delete, owner)) |> response(204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, owner))
      end
    end

    test "401 when not logged in", %{conn: conn, owner: owner} do
      errors =
        Plug.Conn.assign(conn, :current_user, nil)
        |> delete(Routes.user_path(conn, :delete, owner))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "401 for another users", %{conn: conn, owner: owner, another: another} do
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

    {:ok, _} = Dreams.create_dream(owner, FIxture.Dreams.dream())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end
end
