defmodule LILDWeb.Tag.DreamControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.{Dreams, Accounts}

  setup [:create_user, :login_as_owner]

  describe "index" do
    setup [:create_dream]

    test "タグが付いている夢を返す", %{conn: conn, tags: [tag | _], dream: dream} do
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
  end

  defp create_user(_) do
    Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
  end

  defp login_as_owner(%{conn: conn, user: user}) do
    %{conn: Plug.Conn.assign(conn, :current_user, user)}
  end

  defp create_dream(%{user: user}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream}} = Dreams.create_dream(user, Fixture.Dreams.dream(%{"tags" => [tag.name]}))
    {:ok, %{dream: _dream}} = Dreams.create_dream(user, Fixture.Dreams.dream())

    %{dream: dream, tags: tags}
  end
end
