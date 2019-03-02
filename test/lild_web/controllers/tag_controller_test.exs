defmodule LILDWeb.TagControllerTest do
  use LILDWeb.ConnCase

  alias LILD.Dreams

  setup [:create_tag]

  describe "index" do
    test "lists all tags", %{conn: conn, tags: tags} do
      ids =
        get(conn, Routes.tag_path(conn, :index))
        |> json_response(200)
        |> Map.get("data")
        |> Enum.map(&Map.get(&1, "id"))

      Enum.each(tags, fn tag -> assert tag.id in ids end)
    end
  end

  defp create_tag(_) do
    {:ok, tags} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])

    %{tags: tags}
  end
end
