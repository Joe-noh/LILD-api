defmodule LILDWeb.PresignView do
  use LILDWeb, :view

  def render("show.json", %{presign: presign}) do
    %{presign: render_one(presign, __MODULE__, "presign.json")}
  end

  def render("presign.json", %{presign: presign}) do
    %{url: presign.url}
  end
end
