defmodule LILDWeb.RequireLoginPlugTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.Accounts
  alias LILDWeb.RequireLoginPlug

  @state RequireLoginPlug.init([])

  describe "logged in" do
    setup [:create_user]

    test "pass when logged in", %{conn: conn, user: user} do
      conn = Plug.Conn.assign(conn, :current_user, user) |> RequireLoginPlug.call(@state)

      assert conn.status == nil
      assert conn.halted == false
    end

    defp create_user(_) do
      Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    end
  end

  describe "not logged in" do
    test "401 when not logged in", %{conn: conn} do
      conn = RequireLoginPlug.call(conn, @state)

      assert conn.status == 401
      assert conn.halted == true
    end
  end
end
