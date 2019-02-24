defmodule LILDWeb.UserController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILD.Accounts.User

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"user" => user_params = %{"id_token" => id_token}}) do
    with {:ok, payload} <- Accounts.verify_id_token(id_token),
         %{"firebase" => %{"sign_in_provider" => provider}, "user_id" => uid} = payload,
         firebase_account_params = %{provider: provider, uid: uid},
         {:ok, %{user: %User{} = user}} <- Accounts.create_user(user_params, firebase_account_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
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

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
