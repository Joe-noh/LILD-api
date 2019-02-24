defmodule LILDWeb.UserController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILD.Accounts.User

  action_fallback LILDWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, payload} <- Accounts.verify_id_token(Map.get(user_params, "id_token")),
         firebase_account_params = extract_firebase_account_params(payload),
         {:ok, %{user: %User{} = user}} <- Accounts.create_user(user_params, firebase_account_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    else
      {:error, _, changeset, _} ->
        {:error, changeset}
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

    with {:ok, _} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp extract_firebase_account_params(payload) do
    %{
      "firebase" => %{
        "sign_in_provider" => provider,
        "identities" => identities
      },
      "user_id" => firebase_uid
    } = payload

    provider_uid = Map.get(identities, provider) |> List.first()

    %{firebase_uid: firebase_uid, provider_uid: provider_uid, provider: provider}
  end
end
