defmodule LILDWeb.Tag.DreamControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.{Dreams, Accounts}

  setup [:create_user, :login_as_owner]

  describe "index" do
    setup [:create_dream, :report_dream]

    test "タグが付いていて、かつ通報していない夢を返す", %{conn: conn, tags: [tag | _], dreams: [dream | _]} do
      [tagged_dream] =
        get(conn, Routes.tag_dream_path(conn, :index, tag))
        |> json_response(200)
        |> Map.get("dreams")

      assert tagged_dream["id"] == dream.id
    end

    test "ページネーションする", %{conn: conn, tags: [tag | _]} do
      metadata =
        get(conn, Routes.tag_dream_path(conn, :index, tag))
        |> json_response(200)
        |> Map.get("metadata")

      assert %{"before" => _, "after" => _} = metadata
    end

    test "ログインしていなくても夢を返す", %{conn: conn, tags: [tag | _]} do
      dreams =
        conn
        |> Plug.Conn.assign(:current_user, nil)
        |> get(Routes.tag_dream_path(conn, :index, tag))
        |> json_response(200)
        |> Map.get("dreams")

      assert length(dreams) == 2
    end
  end

  defp create_user(_) do
    {:ok, %{user: user}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    %{user: user, another: another}
  end

  defp login_as_owner(%{conn: conn, user: user}) do
    %{conn: Plug.Conn.assign(conn, :current_user, user)}
  end

  defp create_dream(%{user: user, another: another}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream1}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => false, "secret" => false, "tags" => [tag.name]}))
    {:ok, %{dream: dream2}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false, "tags" => [tag.name]}))
    {:ok, %{dream: dream3}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    %{dreams: [dream1, dream2, dream3], tags: tags}
  end

  defp report_dream(%{user: user, dreams: [_, dream2 | _]}) do
    {:ok, _} = Dreams.report_dream(user, dream2)
    :ok
  end
end
