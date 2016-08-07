defmodule Conspire.Web.CollusionChannelTest do
  use Conspire.Web.ChannelCase
  import TestHelper

  alias Conspire.Web.CollusionChannel
  alias Collusions.Collusion.Song

  describe "interacting with a collusion" do
    setup [:start_collusion]

    test "starts the collusion on join", %{id: id} do
      assert is_pid(:global.whereis_name(id))
    end

    test "sends the collusion's state to the client on join", %{id: id} do
      expected_song = Song.init(id)
      assert_push "collusion:state", ^expected_song
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
