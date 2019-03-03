defmodule LILDWeb.UserController do
  use LILDWeb, :controller

  alias LILD.Accounts
  alias LILD.Accounts.User

  plug LILDWeb.RequireLoginPlug when action in [:show, :update, :delete]
  plug :check_access_restrictions when action in [:update, :delete]

  action_fallback LILDWeb.FallbackController

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, payload} <- Accounts.verify_id_token(Map.get(user_params, "id_token")),
         firebase_account_params = extract_firebase_account_params(payload),
         {:ok, %{user: %User{} = user}} <- Accounts.create_user(user_params, firebase_account_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    else
      {:error, _, changeset, _} ->
        {:error, changeset}
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, _} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  defp extract_firebase_account_params(payload) do
    %{
      "firebase" => %{
        "sign_in_provider" => provider,
        "identities" => identities
      },
      "user_id" => firebase_uid
    } = payload

    provider_uid = Map.get(identities, provider) |> List.first()

    %{firebase_uid: firebase_uid, provider_uid: provider_uid, provider: provider}
  end

  defp check_access_restrictions(conn, _) do
    if conn.assigns.current_user.id == conn.params["id"] do
      conn
    else
      conn
      |> LILDWeb.FallbackController.call({:error, :unauthorized})
      |> Plug.Conn.halt()
    end
  end

  alias OpenApiSpex.Operation

  def open_api_operation(action) do
    apply(__MODULE__, :"#{action}_operation", [])
  end

  def show_operation() do
    %Operation{
      tags: ["users"],
      summary: "Get a user",
      description: "Return a single user.",
      operationId: "users.show",
      parameters: [
        Operation.parameter(:id, :path, :string, "User ID", example: "00JN4SVDW0APCBW9E3T44A8MTB")
      ],
      responses: %{
        200 => Operation.response("User", "application/json", LILDWeb.Schemas.UserResponse)
      }
    }
  end

  def create_operation() do
    %Operation{
      tags: ["users"],
      summary: "Signup",
      description: "Create a user.",
      operationId: "users.create",
      requestBody: Operation.request_body("User parameters", "application/json", LILDWeb.Schemas.SignupRequest),
      responses: %{
        201 => Operation.response("User", "application/json", LILDWeb.Schemas.SessionResponse)
      }
    }
  end

  def update_operation() do
    %Operation{
      tags: ["users"],
      summary: "Update a user",
      description: "Update and return specified user.",
      operationId: "users.update",
      parameters: [
        Operation.parameter(:id, :path, :string, "User ID", example: "00JN4SVDW0APCBW9E3T44A8MTB")
      ],
      requestBody: Operation.request_body("User parameters", "application/json", LILDWeb.Schemas.UserRequest),
      responses: %{
        200 => Operation.response("User", "application/json", LILDWeb.Schemas.UserResponse)
      }
    }
  end

  def delete_operation() do
    %Operation{
      tags: ["users"],
      summary: "Delete a user",
      description: "Delete a single user and associated resources.",
      operationId: "users.delete",
      parameters: [
        Operation.parameter(:id, :path, :string, "User ID", example: "00JN4SVDW0APCBW9E3T44A8MTB")
      ],
      responses: %{
        204 => %OpenApiSpex.Response{description: "No content"}
      }
    }
  end
end
