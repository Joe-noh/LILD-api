defmodule LILDWeb.DreamView do
  use LILDWeb, :view
  alias LILDWeb.MetadataView

  def render("index.json", %{dreams: dreams, metadata: metadata}) do
    %{
      dreams: render_many(dreams, __MODULE__, "dream.json"),
      metadata: render_one(metadata, MetadataView, "metadata.json")
    }
  end

  def render("show.json", %{dream: dream}) do
    %{dream: render_one(dream, __MODULE__, "dream.json")}
  end

  def render("dream.json", %{dream: dream}) do
    %{
      id: dream.id,
      body: dream.body,
      date: dream.date,
      secret: dream.secret,
      draft: dream.draft,
      tags: render_many(dream.tags, LILDWeb.TagView, "tag.json"),
      user: render_one(dream.user, LILDWeb.UserView, "user.json")
    }
  end
end
