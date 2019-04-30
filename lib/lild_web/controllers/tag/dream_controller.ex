defmodule LILDWeb.Tag.DreamController do
  use LILDWeb, :controller

  alias LILD.Dreams

  plug :assign_tag

  action_fallback LILDWeb.FallbackController

  def index(conn, params) do
    current_user = Map.get(conn.assigns, :current_user)
    order = [desc: :date, desc: :inserted_at]
    pagenate_opts = [cursor_fields: Keyword.values(order), before: params["before"], after: params["after"]]

    %{entries: dreams, metadata: metadata} =
      conn.assigns.tag
      |> Dreams.dreams_query([:tags, :user])
      |> Dreams.published_dreams(current_user)
      |> Dreams.without_reported_dreams(current_user)
      |> Dreams.ordered(order)
      |> LILD.Repo.paginate(pagenate_opts)

    conn
    |> put_view(LILDWeb.DreamView)
    |> render("index.json", dreams: dreams, metadata: metadata)
  end

  defp assign_tag(conn, _) do
    assign(conn, :tag, Dreams.get_tag!(conn.params["tag_id"]))
  end
end
