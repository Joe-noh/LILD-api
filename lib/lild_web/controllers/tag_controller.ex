defmodule LILDWeb.TagController do
  use LILDWeb, :controller

  alias LILD.Dreams

  action_fallback LILDWeb.FallbackController

  def index(conn, _params) do
    tags = Dreams.list_tags()
    render(conn, "index.json", tags: tags)
  end
end
