defmodule LILDWeb.SessionController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILDWeb.{AccessToken, RefreshToken}

  action_fallback LILDWeb.FallbackController

  def update(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, %{"sub" => user_id}} <- RefreshToken.decode(refresh_token),
         user <- Accounts.get_user!(user_id) do
      {:ok, access_token, _payload} = AccessToken.encode(user)
      {:ok, refresh_token, _payload} = RefreshToken.encode(user)

      conn
      |> render("show.json", user: user, access_token: access_token, refresh_token: refresh_token)
    else
      _ -> {:error, :unauthorized}
    end
  end
end
