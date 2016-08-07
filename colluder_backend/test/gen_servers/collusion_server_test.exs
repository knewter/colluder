defmodule Colluder.GenServers.CollusionServerTest do
  use ExUnit.Case, async: true
  alias ColluderBackend.CollusionServer

  describe "from the ground up" do
    test "can start server" do
      assert {:ok, _pid} = CollusionServer.start()
    end
  end

  describe "new server" do
    setup [:create_server]

    test "has two tracks", %{server: server} do
      assert 2 = CollusionServer.track_count(server)
    end

    test "has 20 slots", %{server: server} do
      assert 20 = CollusionServer.total_slots(server)
    end

    test "can set a given track's slot", %{server: server} do
      assert false == CollusionServer.get_slot(server, 0, 0)
      assert :ok == CollusionServer.set_slot(server, 0, 0, true)
      assert true == CollusionServer.get_slot(server, 0, 0)
    end

    test "adding a track", %{server: server} do
      track_count = CollusionServer.track_count(server)
      assert :ok = CollusionServer.add_track(server)
      assert track_count + 1 == CollusionServer.track_count(server)
    end
  end

  defp create_server(context) do
    {:ok, server} = CollusionServer.start()
    {:ok, put_in(context, [:server], server)}
  end
end
