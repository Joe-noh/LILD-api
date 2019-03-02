defmodule LILDWeb.DreamControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.{Dreams, Accounts}

  setup [:create_users, :login_as_owner]

  describe "index" do
    setup [:create_dream]

    test "すべての夢を返す", %{conn: conn, owner: owner, dream: dream} do
      [first | _] =
        get(conn, Routes.user_dream_path(conn, :index, owner))
        |> json_response(200)
        |> Map.get("data")

      assert first["id"] == dream.id
    end
  end

  describe "create" do
    test "夢とタグをつくる", %{conn: conn, owner: owner} do
      params = Fixture.Dreams.dream(%{"tags" => ["ハッピー"]})

      data =
        post(conn, Routes.user_dream_path(conn, :create, owner), dream: params)
        |> json_response(201)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["body"] == params["body"]
      assert data["date"] == params["date"] |> to_string()
      assert data["secret"] == params["secret"]
      assert data["draft"] == params["draft"]
    end

    test "パラメータがよくないときは422", %{conn: conn, owner: owner} do
      params = Fixture.Dreams.dream(%{"body" => "", "tags" => ["ハッピー"]})

      errors =
        post(conn, Routes.user_dream_path(conn, :create, owner), dream: params)
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "update" do
    setup [:create_dream]

    test "夢とタグを更新する", %{conn: conn, owner: owner, dream: dream} do
      params = Fixture.Dreams.dream(%{"tags" => ["ハッピー"]})

      data =
        put(conn, Routes.user_dream_path(conn, :update, owner, dream), dream: params)
        |> json_response(200)
        |> Map.get("data")

      assert data["id"] |> is_binary
      assert data["body"] == params["body"]
      assert data["date"] == params["date"] |> to_string()
      assert data["secret"] == params["secret"]
      assert data["draft"] == params["draft"]
    end

    test "パラメータがよくないときは422", %{conn: conn, owner: owner, dream: dream} do
      errors =
        put(conn, Routes.user_dream_path(conn, :update, owner, dream), dream: %{"body" => ""})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "他人の夢は更新できない", %{conn: conn, owner: owner, another: another, dream: dream} do
      params = Fixture.Dreams.dream()

      errors =
        assign(conn, :current_user, another)
        |> put(Routes.user_dream_path(conn, :update, owner, dream), dream: params)
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  describe "delete" do
    setup [:create_dream]

    test "夢を消す", %{conn: conn, owner: owner, dream: dream} do
      conn = delete(conn, Routes.user_dream_path(conn, :delete, owner, dream))
      assert response(conn, 204)
    end

    test "他人の夢は消せない", %{conn: conn, owner: owner, another: another, dream: dream} do
      errors =
        assign(conn, :current_user, another)
        |> delete(Routes.user_dream_path(conn, :delete, owner, dream))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_users(_) do
    {:ok, %{user: owner}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.firebase_account())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end

  defp create_dream(%{owner: owner}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream}} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"tags" => [tag.name]}))

    %{dream: dream, tags: tags}
  end
end