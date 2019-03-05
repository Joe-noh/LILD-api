defmodule LILDWeb.My.DreamController do
  use LILDWeb, :controller

  alias LILD.Dreams

  plug LILDWeb.RequireLoginPlug

  action_fallback LILDWeb.FallbackController

  def index(conn, params) do
    pagenate_opts = [cursor_fields: [:date, :inserted_at], before: params["before"], after: params["after"]]

    %{entries: dreams, metadata: metadata} =
      conn.assigns.current_user
      |> Dreams.dreams_query()
      |> Dreams.without_draft_dreams()
      |> LILD.Repo.paginate(pagenate_opts)

    conn
    |> put_view(LILDWeb.DreamView)
    |> render("index.json", dreams: dreams, metadata: metadata)
  end
end
