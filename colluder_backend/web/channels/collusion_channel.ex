defmodule ColluderBackend.CollusionChannel do
  use ColluderBackend.Web, :channel

  def join("collusion:"<>id, _payload, socket) do
    {:ok, pid} = CollusionSupervisor.start_collusion(id)
    {
      :ok,
      socket
        |> Phoenix.Socket.assign(:id, id)
        |> Phoenix.Socket.assign(:pid, pid)
    }
  end

  def handle_in("track:add", _, socket) do
    :ok = socket.assigns[:pid] |> CollusionServer.add_track
    {:reply, :ok, socket}
  end
end
