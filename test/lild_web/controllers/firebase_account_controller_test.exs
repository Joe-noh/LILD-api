defmodule LILDWeb.FirebaseAccountControllerTest do
  use LILDWeb.ConnCase

  alias LILD.Accounts
  alias LILD.Accounts.FirebaseAccount

  @create_attrs %{
    provider: "some provider",
    uid: "some uid"
  }
  @update_attrs %{
    provider: "some updated provider",
    uid: "some updated uid"
  }
  @invalid_attrs %{provider: nil, uid: nil}

  def fixture(:firebase_account) do
    {:ok, firebase_account} = Accounts.create_firebase_account(@create_attrs)
    firebase_account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all firebase_accounts", %{conn: conn} do
      conn = get(conn, Routes.firebase_account_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create firebase_account" do
    test "renders firebase_account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.firebase_account_path(conn, :create), firebase_account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.firebase_account_path(conn, :show, id))

      assert %{
               "id" => id,
               "provider" => "some provider",
               "uid" => "some uid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.firebase_account_path(conn, :create), firebase_account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update firebase_account" do
    setup [:create_firebase_account]

    test "renders firebase_account when data is valid", %{conn: conn, firebase_account: %FirebaseAccount{id: id} = firebase_account} do
      conn = put(conn, Routes.firebase_account_path(conn, :update, firebase_account), firebase_account: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.firebase_account_path(conn, :show, id))

      assert %{
               "id" => id,
               "provider" => "some updated provider",
               "uid" => "some updated uid"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, firebase_account: firebase_account} do
      conn = put(conn, Routes.firebase_account_path(conn, :update, firebase_account), firebase_account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete firebase_account" do
    setup [:create_firebase_account]

    test "deletes chosen firebase_account", %{conn: conn, firebase_account: firebase_account} do
      conn = delete(conn, Routes.firebase_account_path(conn, :delete, firebase_account))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.firebase_account_path(conn, :show, firebase_account))
      end
    end
  end

  defp create_firebase_account(_) do
    firebase_account = fixture(:firebase_account)
    {:ok, firebase_account: firebase_account}
  end
end
