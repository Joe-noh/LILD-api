defmodule LILDWeb.Tag.DreamController do
  use LILDWeb, :controller

  alias LILD.Dreams

  plug LILDWeb.RequireLoginPlug
  plug :assign_tag

  action_fallback LILDWeb.FallbackController

  def index(conn, params) do
    pagenate_opts = [cursor_fields: [:date, :inserted_at], before: params["before"], after: params["after"]]

    %{entries: dreams, metadata: metadata} =
      conn.assigns.tag
      |> Dreams.dreams_query()
      |> Dreams.published_dreams()
      |> LILD.Repo.paginate(pagenate_opts)

    conn
    |> put_view(LILDWeb.DreamView)
    |> render("index.json", dreams: dreams, metadata: metadata)
  end

  defp assign_tag(conn, _) do
    assign(conn, :tag, Dreams.get_tag!(conn.params["tag_id"]))
  end
end
