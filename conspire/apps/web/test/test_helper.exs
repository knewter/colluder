ExUnit.start

defmodule TestHelper do
  def new_id() do
    UUID.uuid4(:hex)
  end
end
