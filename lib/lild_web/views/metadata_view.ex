defmodule LILDWeb.MetadataView do
  use LILDWeb, :view

  def render("metadata.json", %{metadata: metadata}) do
    %{
      before: metadata.before,
      after: metadata.after
    }
  end
end
