defmodule ColluderBackend.CollusionChannel do
  use ColluderBackend.Web, :channel
  import ColluderBackend.CollusionSupervisor, only: [{:start_collusion, 1}]

  def join("collusion:"<>id, payload, socket) do
    {:ok, pid} = start_collusion(id)
    {:ok, socket |> Phoenix.Socket.assign(:id, id)}
  end
end
