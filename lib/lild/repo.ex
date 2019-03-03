defmodule LILD.Repo do
  use Ecto.Repo,
    otp_app: :lild,
    adapter: Ecto.Adapters.Postgres

  use Paginator,
    limit: 20,
    maximum_limit: 100,
    include_total_count: false
end
