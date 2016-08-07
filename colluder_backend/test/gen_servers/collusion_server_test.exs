defmodule Colluder.GenServers.CollusionServerTest do
  use ExUnit.Case, async: true
  alias ColluderBackend.CollusionServer
  import TestHelper

  describe "from the ground up" do
    test "can start server" do
      assert {:ok, _pid} = CollusionServer.start_link(new_id())
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

  describe "trying to start an already-registered server" do
    test "returns existing server as if the start was successful" do
      {:ok, pid} = CollusionServer.start_link(1)
      assert {:ok, ^pid} = CollusionServer.start_link(1)
    end
  end

  defp create_server(context) do
    {:ok, server} = CollusionServer.start_link(new_id())
    {:ok, put_in(context, [:server], server)}
  end
end
