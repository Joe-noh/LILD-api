defmodule LILDWeb.SessionController do
  use LILDWeb, :controller

  alias LILD.Accounts

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"firebase" => %{"id_token" => id_token}}) do
    with {:ok, %{"uid" => uid, "provider" => provider}} <- Accounts.verify_id_token(id_token),
         user when not is_nil(user) <- Accounts.get_user_by_social_account(provider, uid),
         {:ok, token, _payload} <- LILDWeb.AccessToken.encode(user) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user, token: token)
    else
      nil -> {:error, :unauthorized}
    end
  end
end
