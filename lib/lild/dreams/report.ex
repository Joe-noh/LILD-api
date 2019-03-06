defmodule LILD.Dreams.Report do
  use Ecto.Schema
  import Ecto.Changeset

  alias LILD.Accounts.User
  alias LILD.Dreams
  alias LILD.Dreams.Dream

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "reports" do
    belongs_to :user, User
    belongs_to :dream, Dream

    timestamps()
  end

  @doc false
  def changeset(report, attrs) do
    report
    |> cast(attrs, [])
    |> unique_constraint(:dream_id, name: :reports_user_id_dream_id_index)
    |> cannot_report_own_dream()
  end

  defp cannot_report_own_dream(changeset) do
    {_, user_id} = fetch_field(changeset, :user_id)
    {_, dream_id} = fetch_field(changeset, :dream_id)

    case Dreams.get_dream!(dream_id) do
      %{user_id: ^user_id} ->
        add_error(changeset, :dream_id, "Cannot report own dream.")

      _ ->
        changeset
    end
  end
end
