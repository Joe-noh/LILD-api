defmodule LILDWeb.RequireLoginPlug do
  def init(_), do: nil

  def call(conn, _) do
    if Map.get(conn.assigns, :current_user) do
      conn
    else
      conn
      |> LILDWeb.FallbackController.call({:error, :unauthorized})
      |> Plug.Conn.halt()
    end
  end
end
