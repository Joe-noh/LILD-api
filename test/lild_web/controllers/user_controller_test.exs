defmodule LILDWeb.UserControllerTest do
  use LILDWeb.ConnCase

  import Mock

  alias LILD.Accounts
  alias LILD.Accounts.User

  @create_attrs %{
    avatar_url: "some avatar_url",
    name: "some name",
    id_token: "firebase.id_token"
  }
  @update_attrs %{
    avatar_url: "some updated avatar_url",
    name: "some updated name"
  }
  @invalid_attrs %{avatar_url: nil, name: nil, id_token: nil}

  @firebase_response %{
    "aud" => "lild-dev",
    "auth_time" => 1_550_966_987,
    "exp" => 1_550_970_587,
    "firebase" => %{
      "identities" => %{"twitter.com" => ["872977718727458816"]},
      "sign_in_provider" => "twitter.com"
    },
    "iat" => 1_550_966_987,
    "iss" => "https://securetoken.google.com/lild-dev",
    "name" => "paintgraphics",
    "picture" => "https://abs.twimg.com/sticky/default_profile_images/default_profile_normal.png",
    "sub" => "tR7hx0eEqeZYYOM9mODVmM39TUP2",
    "user_id" => "tR7hx0eEqeZYYOM9mODVmM39TUP2"
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test_with_mock "renders user when data is valid", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "avatar_url" => "some avatar_url",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test_with_mock "renders errors when data is invalid", %{conn: conn}, Accounts, [:passthrough], verify_id_token: fn _ -> {:ok, @firebase_response} end do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "avatar_url" => "some updated avatar_url",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
