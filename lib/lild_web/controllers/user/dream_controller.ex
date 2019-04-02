defmodule LILDWeb.User.DreamController do
  use LILDWeb, :controller

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.Dream

  plug LILDWeb.RequireLoginPlug
  plug :check_access_restrictions when action in [:update, :delete]
  plug :assign_user
  plug :assign_dream when action in [:show, :update, :delete]

  action_fallback LILDWeb.FallbackController

  def index(conn, params) do
    order = [desc: :date, desc: :inserted_at]
    pagenate_opts = [cursor_fields: Keyword.values(order), before: params["before"], after: params["after"]]

    %{entries: dreams, metadata: metadata} =
      conn.assigns.user
      |> Dreams.dreams_query([:tags, :user])
      |> Dreams.published_dreams(conn.assigns.current_user)
      |> Dreams.without_reported_dreams(conn.assigns.current_user)
      |> Dreams.ordered(order)
      |> LILD.Repo.paginate(pagenate_opts)

    conn
    |> put_view(LILDWeb.DreamView)
    |> render("index.json", dreams: dreams, metadata: metadata)
  end

  def create(conn, %{"dream" => dream_params}) do
    with user = conn.assigns.current_user,
         {:ok, %{dream: %Dream{} = dream}} <- Dreams.create_dream(user, dream_params) do
      dream = Dreams.dreams_query(dream, [:tags, :user]) |> LILD.Repo.one()

      conn
      |> put_status(:created)
      |> put_view(LILDWeb.DreamView)
      |> render("show.json", dream: dream)
    else
      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def show(conn, _params) do
    render(conn, "show.json", dream: conn.assigns.dream)
  end

  def update(conn, %{"dream" => dream_params}) do
    with dream = conn.assigns.dream,
         {:ok, %{dream: %Dream{} = dream}} <- Dreams.update_dream(dream, dream_params) do
      dream = Dreams.dreams_query(dream, [:tags, :user]) |> LILD.Repo.one()

      conn
      |> put_view(LILDWeb.DreamView)
      |> render("show.json", dream: dream)
    else
      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def delete(conn, _params) do
    with dream = conn.assigns.dream,
         {:ok, %Dream{}} <- Dreams.delete_dream(dream) do
      send_resp(conn, :no_content, "")
    end
  end

  defp check_access_restrictions(conn, _) do
    if conn.assigns.current_user.id == conn.params["user_id"] do
      conn
    else
      conn
      |> LILDWeb.FallbackController.call({:error, :unauthorized})
      |> Plug.Conn.halt()
    end
  end

  defp assign_user(conn, _) do
    assign(conn, :user, Accounts.get_user!(conn.params["user_id"]))
  end

  defp assign_dream(conn, _) do
    assign(conn, :dream, Dreams.get_dream!(conn.assigns.user, conn.params["id"]))
  end
end
