defmodule LILDWeb.FirebaseAccountView do
  use LILDWeb, :view
  alias LILDWeb.FirebaseAccountView

  def render("index.json", %{firebase_accounts: firebase_accounts}) do
    %{data: render_many(firebase_accounts, FirebaseAccountView, "firebase_account.json")}
  end

  def render("show.json", %{firebase_account: firebase_account}) do
    %{data: render_one(firebase_account, FirebaseAccountView, "firebase_account.json")}
  end

  def render("firebase_account.json", %{firebase_account: firebase_account}) do
    %{id: firebase_account.id, uid: firebase_account.uid, provider: firebase_account.provider}
  end
end
