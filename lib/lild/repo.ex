defmodule LILD.Repo do
  use Ecto.Repo,
    otp_app: :lild,
    adapter: Ecto.Adapters.Postgres
end
