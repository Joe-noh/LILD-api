defmodule LILDWeb.DreamView do
  use LILDWeb, :view

  def render("dream.json", %{dream: dream}) do
    %{
      id: dream.id,
      body: dream.body,
      date: dream.date,
      secret: dream.secret,
      draft: dream.draft
    }
  end
end
