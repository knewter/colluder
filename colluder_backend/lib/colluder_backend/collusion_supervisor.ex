defmodule ColluderBackend.CollusionSupervisor do
  use Supervisor
  @name CollusionSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def start_collusion(id) do
    Supervisor.start_child(@name, [id])
  end

  def init(_) do
    children = [
      worker(ColluderBackend.CollusionServer, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
