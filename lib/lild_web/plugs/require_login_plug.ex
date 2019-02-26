defmodule LILDWeb.RequireLoginPlug do
  def init(_), do: nil

  def call(conn, _) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> Plug.Conn.put_status(:unauthorized)
      |> Phoenix.Controller.put_view(LILDWeb.ErrorView)
      |> Phoenix.Controller.render("401.json")
      |> Plug.Conn.halt()
    end
  end
end
