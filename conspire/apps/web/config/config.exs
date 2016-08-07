# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :web,
  namespace: Conspire.Web

# Configures the endpoint
config :web, Conspire.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FkAjq4JOcq2id64OdgkDA3g8cQo0g4aWv0LP6utKNfHq7LY+zV3NiXk7NFF8k+h3",
  render_errors: [view: Conspire.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Conspire.Web.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
