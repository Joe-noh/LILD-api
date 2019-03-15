defmodule LILDWeb.TagControllerTest do
  use LILDWeb.ConnCase

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

  defp create_tag(_) do
    {:ok, tags} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])

    %{tags: tags}
  end
end
