defmodule LILDWeb.DreamControllerTest do
  use LILDWeb.ConnCase

  alias LILD.{Dreams, Accounts}

  setup [:create_users, :login_as_owner]

  describe "index" do
    setup [:create_dream]

    test "lists all dreams", %{conn: conn, owner: owner, dream: dream} do
      [first | _] =
        get(conn, Routes.user_dream_path(conn, :index, owner))
        |> json_response(200)
        |> Map.get("data")

      assert first["id"] == dream.id
    end
  end

  describe "create dream" do
    test "renders dream when data is valid", %{conn: conn, owner: owner} do
      params = Fixture.Dreams.dream()

      data =
        post(conn, Routes.user_dream_path(conn, :create, owner), dream: params)
        |> json_response(201)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["body"] == params[:body]
      assert data["date"] == params[:date] |> to_string()
      assert data["secret"] == params[:secret]
      assert data["draft"] == params[:draft]
    end

    test "renders errors when data is invalid", %{conn: conn, owner: owner} do
      errors =
        post(conn, Routes.user_dream_path(conn, :create, owner), dream: %{body: ''})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "update dream" do
    setup [:create_dream]

    test "renders dream when data is valid", %{conn: conn, owner: owner, dream: dream} do
      params = Fixture.Dreams.dream()

      data =
        put(conn, Routes.user_dream_path(conn, :update, owner, dream), dream: params)
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["body"] == params[:body]
      assert data["date"] == params[:date] |> to_string()
      assert data["secret"] == params[:secret]
      assert data["draft"] == params[:draft]
    end

    test "renders errors when data is invalid", %{conn: conn, owner: owner, dream: dream} do
      errors =
        put(conn, Routes.user_dream_path(conn, :update, owner, dream), dream: %{body: ''})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "401 for another user", %{conn: conn, owner: owner, another: another, dream: dream} do
      params = Fixture.Dreams.dream()

      errors =
        assign(conn, :current_user, another)
        |> put(Routes.user_dream_path(conn, :update, owner, dream), dream: params)
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "delete dream" do
    setup [:create_dream]

    test "deletes chosen dream", %{conn: conn, owner: owner, dream: dream} do
      conn = delete(conn, Routes.user_dream_path(conn, :delete, owner, dream))
      assert response(conn, 204)
    end

    test "401 for another user", %{conn: conn, owner: owner, another: another, dream: dream} do
      errors =
        assign(conn, :current_user, another)
        |> delete(Routes.user_dream_path(conn, :delete, owner, dream))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_users(_) do
    {:ok, %{user: owner}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end

  defp create_dream(%{owner: owner}) do
    {:ok, dream} = Dreams.create_dream(owner, Fixture.Dreams.dream())

    %{dream: dream}
  end
end
