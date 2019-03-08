defmodule LILDWeb.SignatureController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILD.Accounts.User

  # plug LILDWeb.RequireLoginPlug

  action_fallback LILDWeb.FallbackController

  def create(conn, _params) do
    signature = LILDWeb.S3Signature.sign("aaa.jpg", "image/jpg")

    conn
    |> put_status(:created)
    |> render("show.json", signature: signature)
  end
end
