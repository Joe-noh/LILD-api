defmodule LILDWeb.User.DreamControllerTest do
  use LILDWeb.ConnCase, async: true

  alias LILD.{Dreams, Accounts}

  setup [:create_users, :login_as_owner]

  describe "index" do
    setup [:create_dream, :report_dream]

    test "通報していないすべての夢を返す", %{conn: conn, owner: owner, dreams: [_, reported_dream | _]} do
      get(conn, Routes.user_dream_path(conn, :index, owner))
      |> json_response(200)
      |> Map.get("dreams")
      |> Enum.each(fn dream ->
        assert dream["id"] != reported_dream.id
      end)
    end

    test "ページネーションする", %{conn: conn, owner: owner} do
      metadata =
        get(conn, Routes.user_dream_path(conn, :index, owner))
        |> json_response(200)
        |> Map.get("metadata")

      assert %{"before" => _, "after" => _} = metadata
    end
  end

  describe "create" do
    test "夢とタグをつくる", %{conn: conn, owner: owner} do
      params = Fixture.Dreams.dream(%{"tags" => ["ハッピー"]})

      json =
        post(conn, Routes.user_dream_path(conn, :create, owner), dream: params)
        |> json_response(201)
        |> Map.get("dream")

      assert json["id"] |> is_binary
      assert json["body"] == params["body"]
      assert json["date"] == params["date"] |> to_string()
      assert json["secret"] == params["secret"]
      assert json["draft"] == params["draft"]
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

    test "夢とタグを更新する", %{conn: conn, owner: owner, dreams: [dream | _]} do
      params = Fixture.Dreams.dream(%{"tags" => ["ハッピー"]})

      json =
        put(conn, Routes.user_dream_path(conn, :update, owner, dream), dream: params)
        |> json_response(200)
        |> Map.get("dream")

      assert json["id"] |> is_binary
      assert json["body"] == params["body"]
      assert json["date"] == params["date"] |> to_string()
      assert json["secret"] == params["secret"]
      assert json["draft"] == params["draft"]
    end

    test "パラメータがよくないときは422", %{conn: conn, owner: owner, dreams: [dream | _]} do
      errors =
        put(conn, Routes.user_dream_path(conn, :update, owner, dream), dream: %{"body" => ""})
        |> json_response(422)
        |> Map.get("errors")

      assert errors != %{}
    end

    test "他人の夢は更新できない", %{conn: conn, owner: owner, another: another, dreams: [dream | _]} do
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

    test "夢を消す", %{conn: conn, owner: owner, dreams: [dream | _]} do
      conn = delete(conn, Routes.user_dream_path(conn, :delete, owner, dream))
      assert response(conn, 204)
    end

    test "他人の夢は消せない", %{conn: conn, owner: owner, another: another, dreams: [dream | _]} do
      errors =
        assign(conn, :current_user, another)
        |> delete(Routes.user_dream_path(conn, :delete, owner, dream))
        |> json_response(401)
        |> Map.get("errors")

      assert errors != %{}
    end
  end

  defp create_users(_) do
    {:ok, %{user: owner}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
    {:ok, %{user: another}} = Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())

    %{owner: owner, another: another}
  end

  defp login_as_owner(%{conn: conn, owner: owner}) do
    %{conn: Plug.Conn.assign(conn, :current_user, owner)}
  end

  defp create_dream(%{owner: owner, another: another}) do
    {:ok, tags = [tag | _]} = Dreams.create_tags(["nightmare", "予知夢好きと繋がりたい"])
    {:ok, %{dream: dream1}} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => false, "secret" => false, "tags" => [tag.name]}))
    {:ok, %{dream: dream2}} = Dreams.create_dream(another, Fixture.Dreams.dream(%{"draft" => false, "secret" => false, "tags" => [tag.name]}))
    {:ok, %{dream: dream3}} = Dreams.create_dream(owner, Fixture.Dreams.dream(%{"draft" => false, "secret" => false}))

    %{dreams: [dream1, dream2, dream3], tags: tags}
  end

  defp report_dream(%{owner: owner, another: another, dreams: [owner_dream, another_dream | _]}) do
    {:ok, _} = Dreams.report_dream(owner, another_dream)
    {:ok, _} = Dreams.report_dream(another, owner_dream)
    :ok
  end
end
