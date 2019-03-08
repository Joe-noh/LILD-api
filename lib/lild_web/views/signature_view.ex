defmodule LILDWeb.SignatureView do
  use LILDWeb, :view

  def render("show.json", %{signature: signature}) do
    %{signature: render_one(signature, __MODULE__, "signature.json")}
  end

  def render("signature.json", %{signature: signature}) do
    signature
  end
end
