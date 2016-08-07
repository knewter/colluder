defmodule ColluderBackend.CollusionSupervisorTest do
  use ExUnit.Case, async: true
  import TestHelper
  alias ColluderBackend.CollusionSupervisor

  describe "creating new collusions" do
    test "creating a nonexistent collusion" do
      assert {:ok, _pid} = CollusionSupervisor.start_collusion(new_id())
    end

    test "trying to start a collusion that already exists" do
      # returns the existing collusion as if the creation was successful
      id = new_id()
      {:ok, pid} = CollusionSupervisor.start_collusion(id)
      assert {:ok, ^pid} = CollusionSupervisor.start_collusion(id)
    end
  end
end
