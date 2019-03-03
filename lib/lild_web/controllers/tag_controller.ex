defmodule LILDWeb.TagController do
  use LILDWeb, :controller

  alias LILD.Dreams

  action_fallback LILDWeb.FallbackController

  def index(conn, _params) do
    tags = Dreams.list_tags()
    render(conn, "index.json", tags: tags)
  end

  alias OpenApiSpex.Operation

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def index_operation() do
    %Operation{
      tags: ["tags"],
      summary: "Search tags",
      description: "Search and list tags that match given query.",
      operationId: "tags.index",
      parameters: [
        Operation.parameter(:q, :query, :string, "Search query", example: "nightmare")
      ],
      responses: %{
        200 => Operation.response("Tag", "application/json", LILDWeb.Schemas.TagsResponse)
      }
    }
  end
end
