defmodule LILDWeb.Tag.DreamView do
  use LILDWeb, :view
  alias LILDWeb.{DreamView, MetadataView}

  def render("index.json", %{dreams: dreams, metadata: metadata}) do
    %{
      dreams: render_many(dreams, DreamView, "dream.json"),
      metadata: render_one(metadata, MetadataView, "metadata.json")
    }
  end
end
