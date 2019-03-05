defmodule LILDWeb.My.Dream.DraftController do
  use LILDWeb, :controller

  alias LILD.Dreams

  plug LILDWeb.RequireLoginPlug

  action_fallback LILDWeb.FallbackController

  def index(conn, params) do
    order = [desc: :date, desc: :inserted_at]
    pagenate_opts = [cursor_fields: Keyword.values(order), before: params["before"], after: params["after"]]

    %{entries: dreams, metadata: metadata} =
      conn.assigns.current_user
      |> Dreams.dreams_query()
      |> Dreams.only_draft_dreams()
      |> Dreams.ordered(order)
      |> LILD.Repo.paginate(pagenate_opts)

    conn
    |> put_view(LILDWeb.DreamView)
    |> render("index.json", dreams: dreams, metadata: metadata)
  end
end
