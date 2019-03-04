defmodule LILDWeb.SocialAccountView do
  use LILDWeb, :view

  def render("index.json", %{social_accounts: social_accounts}) do
    %{social_accounts: render_many(social_accounts, __MODULE__, "social_account.json")}
  end

  def render("social_account.json", %{social_account: social_account}) do
    %{
      uid: social_account.uid,
      provider: social_account.provider
    }
  end
end
