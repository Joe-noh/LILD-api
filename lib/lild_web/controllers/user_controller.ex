defmodule LILDWeb.UserController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILD.Accounts.User

  plug LILDWeb.RequireLoginPlug when action in [:show, :update, :delete]
  plug :check_access_restrictions when action in [:update, :delete]

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"id_token" => id_token}) do
    with {:ok, user_params, social_account_params = %{"uid" => uid, "provider" => provider}} <- Accounts.verify_id_token(id_token) do
      case Accounts.get_user_by_social_account(provider, uid) do
        nil -> handle_new_user(conn, user_params, social_account_params)
        user -> handle_authenticated(conn, user)
      end
    else
      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  defp handle_new_user(conn, user_params, social_account_params) do
    case Accounts.create_user(user_params, social_account_params) do
      {:ok, %{user: %User{} = user}} -> handle_authenticated(conn, user)
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp handle_authenticated(conn, user) do
    {:ok, access_token, _payload} = LILDWeb.AccessToken.encode(user)
    {:ok, refresh_token, _payload} = LILDWeb.RefreshToken.encode(user)

    conn
    |> put_status(:created)
    |> put_view(LILDWeb.SessionView)
    |> render("show.json", user: user, access_token: access_token, refresh_token: refresh_token)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, _} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp check_access_restrictions(conn, _) do
    if conn.assigns.current_user.id == conn.params["id"] do
      conn
    else
      conn
      |> LILDWeb.FallbackController.call({:error, :unauthorized})
      |> Plug.Conn.halt()
    end
  end
end
