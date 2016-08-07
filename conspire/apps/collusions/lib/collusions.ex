defmodule Collusions do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Collusions.CollusionSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: Collusions.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
