defmodule LILDWeb.ReportControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.Accounts
  alias LILD.Dreams

  describe "create" do
    setup [:create_users, :login_as_user, :create_dreams]

    test "他人の夢を通報できる", %{conn: conn, another: another, dreams: [_, another_dream | _]} do
      json =
        post(conn, Routes.user_dream_report_path(conn, :create, another, another_dream))
        |> json_response(201)

      assert json["report"]["user_id"] == conn.assigns.current_user.id
      assert json["report"]["dream_id"] == another_dream.id
    end

    test "自分の夢は通報できない", %{conn: conn, user: user, dreams: [user_dream | _]} do
      errors =
        post(conn, Routes.user_dream_report_path(conn, :create, user, user_dream))
        |> json_response(400)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_users(_) do
    {:ok, %{user: user}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    %{user: user, another: another}
  end

  defp login_as_user(%{conn: conn, user: user}) do
    %{conn: Plug.Conn.assign(conn, :current_user, user)}
  end

  defp create_dreams(%{user: user, another: another}) do
    {:ok, %{dream: user_dream}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))
    {:ok, %{dream: another_dream}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    %{dreams: [user_dream, another_dream]}
  end
end
