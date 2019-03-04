defmodule LILDWeb.User.DreamView do
  use LILDWeb, :view
  alias LILDWeb.{DreamView, MetadataView}

  def render("index.json", %{dreams: dreams, metadata: metadata}) do
    %{
      dreams: render_many(dreams, DreamView, "dream.json"),
      metadata: render_one(metadata, MetadataView, "metadata.json")
    }
  end

  def render("show.json", %{dream: dream}) do
    %{dream: render_one(dream, DreamView, "dream.json")}
  end
end
