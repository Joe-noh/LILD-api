defmodule LILDWeb.TagControllerTest do
  use LILDWeb.ConnCase

  alias LILD.Dreams

  @create_attrs %{
    name: "some name"
  }

  def fixture(:tag) do
    {:ok, tag} = Dreams.create_tag(@create_attrs)
    tag
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tags", %{conn: conn} do
      conn = get(conn, Routes.tag_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  defp create_tag(_) do
    tag = fixture(:tag)
    {:ok, tag: tag}
  end
end
