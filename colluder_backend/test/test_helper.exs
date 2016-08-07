ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(ColluderBackend.Repo, :manual)

defmodule TestHelper do
  def new_id() do
    UUID.uuid4(:hex)
  end
end
