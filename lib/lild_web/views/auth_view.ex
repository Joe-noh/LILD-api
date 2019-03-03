defmodule LILDWeb.AuthView do
  use LILDWeb, :view

  def render("auth.json", %{auth: token}) do
    %{token: token}
  end
end
