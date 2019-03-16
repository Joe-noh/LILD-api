defmodule LILDWeb.TagController do
  use LILDWeb, :controller

  alias LILD.Dreams

  action_fallback LILDWeb.FallbackController

  def index(conn, %{"q" => query}) do
    tags = Dreams.search_tags_query(Dreams.Tag, query) |> LILD.Repo.all
    render(conn, "index.json", tags: tags)
  end
end
