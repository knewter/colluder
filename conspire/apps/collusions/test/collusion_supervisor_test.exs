defmodule Collusions.CollusionSupervisorTest do
  use ExUnit.Case, async: true
  import TestHelper

  describe "creating new collusions" do
    test "creating a nonexistent collusion" do
      assert {:ok, _pid} = Collusions.Supervisor.start_collusion(new_id())
    end

    test "trying to start a collusion that already exists" do
      # returns the existing collusion as if the creation was successful
      id = new_id()
      {:ok, pid} = Collusions.Supervisor.start_collusion(id)
      assert {:ok, ^pid} = Collusions.Supervisor.start_collusion(id)
    end
  end
end
