defmodule LILDWeb.PresignController do
  use LILDWeb, :controller

  alias LILD.S3

  plug LILDWeb.RequireLoginPlug

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"mimetype" => mimetype}) do
    with {:ok, presign} <- S3.presign_for_avatar(conn.assigns.current_user, mimetype) do
      conn
      |> put_status(:created)
      |> render("show.json", presign: presign)
    else
      _ -> {:error, :bad_request}
    end
  end
end
