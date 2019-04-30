# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lild,
  namespace: LILD,
  ecto_repos: [LILD.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :lild, LILDWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "wp52kBDOeg9Zj4oj0Mx5QnbwBhHNkjI845gqv2+tt9CObYI6Cq68jTPmO/lW9cDD",
  render_errors: [view: LILDWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LILD.PubSub, adapter: Phoenix.PubSub.PG2]

config :lild, :s3,
  region: "us-west-2",
  bucket: System.get_env("AWS_BUCKET"),
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :filter_parameters, ["password", "refresh_token", "id_token"]

config :joken,
  hs256: [signer_alg: "HS256", key_octet: "jLFZX/tV0rMcQFMWPo0Y9SgDOUMvHK3nSXrTdrEmMmsNg7VI17jKfbNHDEAqZxAg"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
