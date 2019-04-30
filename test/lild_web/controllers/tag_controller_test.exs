defmodule LILDWeb.TagControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.Dreams

  setup [:create_tag]

  describe "index" do
    test "タグを名前で検索して返す", %{conn: conn, tags: [nightmare | _]} do
      [tag] =
        get(conn, Routes.tag_path(conn, :index), q: "night")
        |> json_response(200)
        |> Map.get("tags")

      assert tag["name"] == nightmare.name
    end
  end

  describe "show" do
    test "idからタグを引いて返す", %{conn: conn, tags: [%{id: id} | _]} do
      tag =
        get(conn, Routes.tag_path(conn, :show, id))
        |> json_response(200)
        |> Map.get("tag")

      assert tag["id"] == id
    end
  end

  defp create_tag(_) do
    {:ok, tags} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])

    %{tags: tags}
  end
end
