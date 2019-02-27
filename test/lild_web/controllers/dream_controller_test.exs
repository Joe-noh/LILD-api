defmodule LILDWeb.DreamControllerTest do
  use LILDWeb.ConnCase

  alias LILD.Dreams
  alias LILD.Dreams.Dream

  @create_attrs %{
    body: "some body",
    date: ~D[2010-04-17],
    draft: true,
    secret: true
  }
  @update_attrs %{
    body: "some updated body",
    date: ~D[2011-05-18],
    draft: false,
    secret: false
  }
  @invalid_attrs %{body: nil, date: nil, draft: nil, secret: nil}

  def fixture(:dream) do
    {:ok, dream} = Dreams.create_dream(@create_attrs)
    dream
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all dreams", %{conn: conn} do
      conn = get(conn, Routes.dream_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create dream" do
    test "renders dream when data is valid", %{conn: conn} do
      conn = post(conn, Routes.dream_path(conn, :create), dream: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.dream_path(conn, :show, id))

      assert %{
               "id" => id,
               "body" => "some body",
               "date" => "2010-04-17",
               "draft" => true,
               "secret" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.dream_path(conn, :create), dream: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update dream" do
    setup [:create_dream]

    test "renders dream when data is valid", %{conn: conn, dream: %Dream{id: id} = dream} do
      conn = put(conn, Routes.dream_path(conn, :update, dream), dream: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.dream_path(conn, :show, id))

      assert %{
               "id" => id,
               "body" => "some updated body",
               "date" => "2011-05-18",
               "draft" => false,
               "secret" => false
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, dream: dream} do
      conn = put(conn, Routes.dream_path(conn, :update, dream), dream: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete dream" do
    setup [:create_dream]

    test "deletes chosen dream", %{conn: conn, dream: dream} do
      conn = delete(conn, Routes.dream_path(conn, :delete, dream))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.dream_path(conn, :show, dream))
      end
    end
  end

  defp create_dream(_) do
    dream = fixture(:dream)
    {:ok, dream: dream}
  end
end
