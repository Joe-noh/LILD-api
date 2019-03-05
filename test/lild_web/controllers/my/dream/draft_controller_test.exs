defmodule LILDWeb.My.Dream.DraftControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.{Dreams, Accounts}

  setup [:create_users, :login_as_owner]

  describe "index" do
    setup [:create_dreams]

    test "ログインユーザの夢を下書きだけ返す", %{conn: conn, owner: owner} do
      dreams = Dreams.dreams_query(owner) |> LILD.Repo.all()

      get(conn, Routes.my_dream_draft_path(conn, :index))
      |> json_response(200)
      |> Map.get("dreams")
      |> Enum.each(fn dream ->
        assert dream["id"] in Enum.map(dreams, & &1.id)
        assert dream["draft"] == true
      end)
    end

    test "ページネーションする", %{conn: conn} do
      metadata =
        get(conn, Routes.my_dream_draft_path(conn, :index))
        |> json_response(200)
        |> Map.get("metadata")

      assert %{"before" => _, "after" => _} = metadata
    end

    test "ログインしていないときは401", %{conn: conn} do
      conn
      |> assign(:current_user, nil)
      |> get(Routes.my_dream_draft_path(conn, :index))
      |> json_response(401)
    end
  end

  defp create_users(_) do
    {:ok, %{user: owner}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end

  defp create_dreams(%{owner: owner, another: another}) do
    {:ok, _} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => true, "secret" => true}))
    {:ok, _} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => true, "secret" => false}))
    {:ok, _} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    {:ok, _} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => true, "secret" => true}))
    {:ok, _} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => true, "secret" => false}))
    {:ok, _} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    :ok
  end
end
