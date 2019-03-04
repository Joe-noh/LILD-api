defmodule LILDWeb.CurrentUserPlugTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.Accounts
  alias LILDWeb.{CurrentUserPlug, AccessToken}

  @state CurrentUserPlug.init([])

  setup [:create_user]

  test "assign :current_user if valid token is in header", %{conn: conn, user: user, access_token: access_token} do
    conn =
      Plug.Conn.put_req_header(conn, "authorization", "Bearer #{access_token}")
      |> CurrentUserPlug.call(@state)

    assert conn.assigns[:current_user] == user
  end

  test "ignore invalid access token", %{conn: conn} do
    conn =
      Plug.Conn.put_req_header(conn, "authorization", "Bearer a")
      |> CurrentUserPlug.call(@state)

    assert conn.assigns == %{}
  end

  test "ignore non-existent users' token", %{conn: conn} do
    {:ok, access_token, _payload} = AccessToken.encode(%{id: Ecto.ULID.generate()})

    conn =
      Plug.Conn.put_req_header(conn, "authorization", "Bearer #{access_token}")
      |> CurrentUserPlug.call(@state)

    assert conn.assigns == %{}
  end

  defp create_user(_) do
    {:ok, %{user: user}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, access_token, _payload} = AccessToken.encode(user)

    %{user: user, access_token: access_token}
  end
end
