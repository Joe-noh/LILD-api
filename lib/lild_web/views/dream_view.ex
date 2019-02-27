defmodule LILDWeb.DreamView do
  use LILDWeb, :view
  alias LILDWeb.DreamView

  def render("index.json", %{dreams: dreams}) do
    %{data: render_many(dreams, DreamView, "dream.json")}
  end

  def render("show.json", %{dream: dream}) do
    %{data: render_one(dream, DreamView, "dream.json")}
  end

  def render("dream.json", %{dream: dream}) do
    %{id: dream.id,
      body: dream.body,
      date: dream.date,
      secret: dream.secret,
      draft: dream.draft}
  end
end
