defmodule LILDWeb.SessionView do
  use LILDWeb, :view
  alias LILDWeb.UserView

  def render("show.json", %{user: user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      user: render_one(user, UserView, "user.json"),
      auth: %{
        access_token: access_token,
        refresh_token: refresh_token
      }
    }
  end
end
