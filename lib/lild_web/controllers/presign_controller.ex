defmodule LILDWeb.PresignController do
  use LILDWeb, :controller

  alias LILD.S3

  plug LILDWeb.RequireLoginPlug

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"mimetype" => mimetype}) do
    with {:ok, url} <- S3.presigned_url(conn.assigns.current_user, "avatars", mimetype) do
      conn
      |> put_status(:created)
      |> render("show.json", presign: %{url: url})
    else
      _ -> {:error, :bad_request}
    end
  end
end
