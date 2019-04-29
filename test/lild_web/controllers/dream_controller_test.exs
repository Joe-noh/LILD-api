defmodule LILDWeb.DreamControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.{Dreams, Accounts}

  setup [:create_users, :login_as_owner]

  describe "index" do
    setup [:create_dream, :report_dream]

    test "通報していないすべての夢を返す", %{conn: conn, dreams: [_, reported_dream | _]} do
      dreams =
        get(conn, Routes.dream_path(conn, :index))
        |> json_response(200)
        |> Map.get("dreams")

      Enum.each(dreams, fn dream ->
        assert dream["id"] != reported_dream.id
      end)

      assert length(dreams) == 4
    end

    test "ページネーションする", %{conn: conn} do
      metadata =
        get(conn, Routes.dream_path(conn, :index))
        |> json_response(200)
        |> Map.get("metadata")

      assert %{"before" => _, "after" => _} = metadata
    end

    test "ログインしていなくても夢を返す", %{conn: conn} do
      dreams =
        conn
        |> Plug.Conn.assign(:current_user, nil)
        |> get(Routes.dream_path(conn, :index))
        |> json_response(200)
        |> Map.get("dreams")

      assert length(dreams) == 5
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

  defp create_dream(%{owner: owner, another: another}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream1}} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => false, "secret" => false, "tags" => [tag.name]}))
    {:ok, %{dream: dream2}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false, "tags" => [tag.name]}))
    {:ok, %{dream: dream3}} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))
    {:ok, %{dream: dream4}} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => false, "secret" => true}))
    {:ok, %{dream: dream5}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    %{dreams: [dream1, dream2, dream3, dream4, dream5], tags: tags}
  end

  defp report_dream(%{owner: owner, another: another, dreams: [owner_dream, another_dream | _]}) do
    {:ok, _} = Dreams.report_dream(owner, another_dream)
    {:ok, _} = Dreams.report_dream(another, owner_dream)
    :ok
  end
end
