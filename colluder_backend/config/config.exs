# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :colluder_backend,
  ecto_repos: [ColluderBackend.Repo]

# Configures the endpoint
config :colluder_backend, ColluderBackend.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FaEXzAmd5z9uPWZM/ueZ87Pv/xaxd2S0UbRWscn0GajDjFBAQs/ouH8p8mjAZLc2",
  render_errors: [view: ColluderBackend.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ColluderBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
