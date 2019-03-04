defmodule LILDWeb.SessionView do
  use LILDWeb, :view
  alias LILDWeb.UserView

  def render("show.json", %{user: user, token: token}) do
    %{
      user: render_one(user, UserView, "user.json"),
      auth: %{token: token}
    }
  end
end
