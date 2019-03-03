defmodule LILDWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule User do
    OpenApiSpex.schema(%{
      title: "User",
      description: "A user of LILD",
      type: :object,
      properties: %{
        id: %Schema{type: :string},
        name: %Schema{type: :string},
        avatar_url: %Schema{type: :string}
      },
      required: [:name, :avatar_url],
      example: %{
        id: "00JN4SVDW0APCBW9E3T44A8MTB",
        name: "ジョン・ドー",
        avatar_url: "https://example.com/avatar.png"
      }
    })
  end

  defmodule Auth do
    OpenApiSpex.schema(%{
      title: "Auth",
      description: "Auth token for LILD.",
      type: :object,
      properties: %{
        token: %Schema{type: :string}
      },
      required: [:token],
      example: %{
        token: "jwt"
      }
    })
  end

  defmodule Session do
    OpenApiSpex.schema(%{
      title: "Session",
      description: "Session information.",
      type: :object,
      properties: %{
        user: User,
        auth: Auth
      },
      required: [:user, :auth],
      example: %{
        user: %{
          id: "00JN4SVDW0APCBW9E3T44A8MTB",
          name: "ジョン・ドー",
          avatar_url: "https://example.com/avatar.png"
        },
        auth: %{
          token: "jwt"
        }
      }
    })
  end

  defmodule IDToken do
    OpenApiSpex.schema(%{
      title: "IDToken",
      description: "ID token given from Firebase.",
      type: :object,
      properties: %{
        id_token: %Schema{type: :string}
      },
      required: [:id_token],
      example: %{
        id_token: "firebase.id.token"
      }
    })
  end

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

  defmodule SignupRequest do
    OpenApiSpex.schema %{
      title: "SignupRequest",
      description: "Request body for login",
      type: :object,
      properties: %{
        user: User,
        firebase: IDToken
      },
      required: [:user],
      example: %{
        user: %{
          name: "ジョン・ドー",
          avatar_url: "https://example.com/avatar.png"
        },
        firebase: %{
          id_token: "firebase.id.token"
        }
      }
    }
  end

  defmodule UserRequest do
    OpenApiSpex.schema %{
      title: "UserRequest",
      description: "Request body for updating a user",
      type: :object,
      properties: %{
        user: %Schema{anyOf: [User]}
      },
      required: [:user],
      example: %{
        user: %{
          name: "ジョン・ドー",
          avatar_url: "https://example.com/avatar.png"
        }
      }
    }
  end

  defmodule UserResponse do
    OpenApiSpex.schema(%{
      title: "UserResponse",
      description: "Response schema for single user",
      type: :object,
      properties: %{
        data: User
      },
      example: %{
        data: %{
          id: "00JN4SVDW0APCBW9E3T44A8MTB",
          name: "John Doe",
          avatar_url: "https://example.com/avatar.png"
        }
      }
    })
  end

  defmodule SessionResponse do
    OpenApiSpex.schema(%{
      title: "SessionResponse",
      description: "Response schema for logging in as a user",
      type: :object,
      properties: %{
        data: Session
      },
      example: %{
        data: %{
          user: %{
            id: "00JN4SVDW0APCBW9E3T44A8MTB",
            name: "John Doe",
            avatar_url: "https://example.com/avatar.png"
          },
          auth: %{
            token: "jwt"
          }
        }
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
