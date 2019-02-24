defmodule LILDWeb.CurrentUserPlug do
  alias LILDWeb.AccessToken
  alias LILD.Accounts

  def init(_), do: nil

  def call(conn, _) do
    with {:ok, user} <- load_user(conn) do
      conn |> Plug.Conn.assign(:current_user, user)
    else
      _ -> conn
    end
  end

  defp load_user(conn) do
    with ["Bearer " <> jwt | _] <- Plug.Conn.get_req_header(conn, "authorization"),
         {:ok, %{"sub" => user_id}} <- AccessToken.decode(jwt),
         user when user != nil <- Accounts.get_user(user_id) do
      {:ok, user}
    else
      _ -> :error
    end
  end
end
