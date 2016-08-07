use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :colluder_backend, ColluderBackend.Endpoint,
  secret_key_base: "NaiflntnbKeO2qt8jESTCZCiWUNEX5Ahnv6VCVH2ZOsvbL3djJderuxoFq9Dd0nc"

# Configure your database
config :colluder_backend, ColluderBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "colluder_backend_prod",
  pool_size: 20
