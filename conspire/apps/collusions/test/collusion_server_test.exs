defmodule Cullusions.CollusionServerTest do
  use ExUnit.Case, async: true
  alias Collusions.Server
  import TestHelper

  describe "from the ground up" do
    test "can start server" do
      assert {:ok, _pid} = Server.start_link(new_id())
    end
  end

  describe "new server" do
    setup [:create_server]

    test "has two tracks", %{server: server} do
      assert 2 = Server.track_count(server)
    end

    test "has 20 slots", %{server: server} do
      assert 20 = Server.total_slots(server)
    end

    test "can set a given track's slot", %{server: server} do
      assert false == Server.get_slot(server, 0, 0)
      assert :ok == Server.set_slot(server, 0, 0, true)
      assert true == Server.get_slot(server, 0, 0)
    end

    test "adding a track", %{server: server} do
      track_count = Server.track_count(server)
      assert :ok = Server.add_track(server)
      assert track_count + 1 == Server.track_count(server)
    end
  end

  describe "trying to start an already-registered server" do
    test "returns existing server as if the start was successful" do
      {:ok, pid} = Server.start_link(1)
      assert {:ok, ^pid} = Server.start_link(1)
    end
  end

  defp create_server(context) do
    {:ok, server} = Server.start_link(new_id())
    {:ok, put_in(context, [:server], server)}
  end
end
