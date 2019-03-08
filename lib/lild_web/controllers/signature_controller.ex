defmodule LILDWeb.SignatureController do
  use LILDWeb, :controller

  alias LILDWeb.S3Signature

  plug LILDWeb.RequireLoginPlug

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"mimetype" => mimetype}) do
    with true <- S3Signature.valid_mimetype?(mimetype),
         signature = S3Signature.sign(conn.assigns.current_user, "avatars", mimetype) do
      conn
      |> put_status(:created)
      |> render("show.json", signature: signature)
    else
      false -> {:error, :bad_request}
    end
  end
end
