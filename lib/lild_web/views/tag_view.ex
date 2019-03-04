defmodule LILDWeb.TagView do
  use LILDWeb, :view
  alias LILDWeb.TagView

  def render("index.json", %{tags: tags}) do
    %{tags: render_many(tags, TagView, "tag.json")}
  end

  def render("show.json", %{tag: tag}) do
    %{tag: render_one(tag, TagView, "tag.json")}
  end

  def render("tag.json", %{tag: tag}) do
    %{id: tag.id, name: tag.name}
  end
end
