defmodule ColluderBackend.CollusionChannelTest do
  use ColluderBackend.ChannelCase
  import TestHelper

  alias ColluderBackend.CollusionChannel

  describe "interacting with a collusion" do
    setup [:start_collusion]

    test "starts the collusion on join", %{id: id} do
      assert is_pid(:global.whereis_name(id))
    end
  end

  defp start_collusion(_context) do
    id = new_id()
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(CollusionChannel, "collusion:#{id}")

    {:ok, socket: socket, id: id}
  end
end
