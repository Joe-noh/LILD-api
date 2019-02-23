defmodule LILDWeb.FirebaseAccountController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILD.Accounts.FirebaseAccount

  action_fallback LILDWeb.FallbackController

  def index(conn, _params) do
    firebase_accounts = Accounts.list_firebase_accounts()
    render(conn, "index.json", firebase_accounts: firebase_accounts)
  end

  def create(conn, %{"firebase_account" => firebase_account_params}) do
    with {:ok, %FirebaseAccount{} = firebase_account} <- Accounts.create_firebase_account(firebase_account_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.firebase_account_path(conn, :show, firebase_account))
      |> render("show.json", firebase_account: firebase_account)
    end
  end

  def show(conn, %{"id" => id}) do
    firebase_account = Accounts.get_firebase_account!(id)
    render(conn, "show.json", firebase_account: firebase_account)
  end

  def update(conn, %{"id" => id, "firebase_account" => firebase_account_params}) do
    firebase_account = Accounts.get_firebase_account!(id)

    with {:ok, %FirebaseAccount{} = firebase_account} <- Accounts.update_firebase_account(firebase_account, firebase_account_params) do
      render(conn, "show.json", firebase_account: firebase_account)
    end
  end

  def delete(conn, %{"id" => id}) do
    firebase_account = Accounts.get_firebase_account!(id)

    with {:ok, %FirebaseAccount{}} <- Accounts.delete_firebase_account(firebase_account) do
      send_resp(conn, :no_content, "")
    end
  end
end
