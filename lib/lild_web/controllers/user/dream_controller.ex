defmodule LILDWeb.User.DreamController do
  use LILDWeb, :controller

  alias LILD.{Dreams, Accounts}
  alias LILD.Dreams.Dream

  plug LILDWeb.RequireLoginPlug
  plug :check_access_restrictions when action in [:update, :delete]
  plug :assign_user
  plug :assign_dream when action in [:show, :update, :delete]

  action_fallback LILDWeb.FallbackController

  def index(conn, _params) do
    dreams = conn.assigns.user |> Dreams.list_dreams()
    render(conn, "index.json", dreams: dreams)
  end

  def create(conn, %{"dream" => dream_params}) do
    with user = conn.assigns.current_user,
         {:ok, %{dream: %Dream{} = dream}} <- Dreams.create_dream(user, dream_params) do
      conn
      |> put_status(:created)
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
      render(conn, "show.json", dream: dream)
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
