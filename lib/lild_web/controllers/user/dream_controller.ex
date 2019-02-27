defmodule LILDWeb.User.DreamController do
  use LILDWeb, :controller

  alias LILD.Dreams
  alias LILD.Dreams.Dream

  plug LILDWeb.RequireLoginPlug
  plug :check_access_restrictions when action in [:update, :delete]

  action_fallback LILDWeb.FallbackController

  def index(conn, _params) do
    dreams = Dreams.list_dreams()
    render(conn, "index.json", dreams: dreams)
  end

  def create(conn, %{"dream" => dream_params}) do
    with user = conn.assigns.current_user,
         {:ok, %Dream{} = dream} <- Dreams.create_dream(user, dream_params) do
      conn
      |> put_status(:created)
      |> render("show.json", dream: dream)
    end
  end

  def show(conn, %{"id" => id}) do
    dream = Dreams.get_dream!(id)
    render(conn, "show.json", dream: dream)
  end

  def update(conn, %{"id" => id, "dream" => dream_params}) do
    dream = Dreams.get_dream!(id)

    with {:ok, %Dream{} = dream} <- Dreams.update_dream(dream, dream_params) do
      render(conn, "show.json", dream: dream)
    end
  end

  def delete(conn, %{"id" => id}) do
    dream = Dreams.get_dream!(id)

    with {:ok, %Dream{}} <- Dreams.delete_dream(dream) do
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
end
