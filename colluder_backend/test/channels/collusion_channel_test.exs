defmodule ColluderBackend.CollusionChannelTest do
  use ColluderBackend.ChannelCase
  import TestHelper

  alias ColluderBackend.CollusionChannel

  describe "interacting with a collusion" do
    setup [:start_collusion]

    test "starts the collusion on join", %{id: id} do
      assert is_pid(:global.whereis_name(id))
    end

    test "adding a track works", %{socket: socket, pid: pid} do
      assert 2 = CollusionServer.track_count(pid)
      ref = push socket, "track:add", %{}
      assert_reply ref, :ok
      assert 3 = CollusionServer.track_count(pid)
    end
  end

  defp start_collusion(_context) do
    id = new_id()
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(CollusionChannel, "collusion:#{id}")

    pid = :global.whereis_name(id)

    {:ok, socket: socket, id: id, pid: pid}
  end
end
