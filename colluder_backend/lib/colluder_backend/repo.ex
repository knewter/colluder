defmodule ColluderBackend.Repo do
  use Ecto.Repo, otp_app: :colluder_backend
  @dialyzer {:nowarn_function, rollback: 1}
end
