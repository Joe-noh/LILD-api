defmodule LILDWeb.SessionView do
  use LILDWeb, :view
  alias LILDWeb.{UserView, AuthView}

  def render("show.json", session) do
    %{data: render_one(session, __MODULE__, "session.json")}
  end

  def render("session.json", %{session:  %{user: user, token: token}}) do
    %{
      user: render_one(user, UserView, "user.json"),
      auth: render_one(token, AuthView, "auth.json")
    }
  end
end
