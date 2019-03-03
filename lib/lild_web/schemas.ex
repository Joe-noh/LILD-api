defmodule LILDWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule Tag do
    OpenApiSpex.schema(%{
      title: "Tag",
      description: "A tag that can be tagged to dreams",
      type: :object,
      properties: %{
        id: %Schema{type: :string},
        name: %Schema{type: :string, pattern: ~r/\A[^\s]+\z/},
      },
      required: [:name],
      example: %{
        id: "00JN4SVDW0APCBW9E3T44A8MTB",
        name: "nightmare"
      }
    })
  end

  defmodule TagsResponse do
    OpenApiSpex.schema(%{
      title: "TagsResponse",
      description: "Response schema for list of tags",
      type: :object,
      properties: %{
        data: %Schema{type: :array, items: Tag}
      },
      example: %{
        data: [
          %{id: "00JN4SVDW0APCBW9E3T44A8MTB", name: "nightmare"},
          %{id: "00JN4SVDW0APCBW9E3T44A8MTB", name: "留年"}
        ]
      }
    })
  end
end
