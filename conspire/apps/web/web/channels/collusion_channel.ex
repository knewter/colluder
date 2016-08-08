defmodule Conspire.Web.CollusionChannel do
  use Conspire.Web.Web, :channel

  def join("collusion:"<>id, _payload, socket) do
    {:ok, pid} = Collusions.Supervisor.start_collusion(id)
    send(self, :after_join)
    {
      :ok,
      socket
        |> Phoenix.Socket.assign(:id, id)
        |> Phoenix.Socket.assign(:pid, pid)
    }
  end

  def handle_in("track:add", _, socket) do
    :ok = socket.assigns[:pid] |> Collusions.Server.add_track
    {:reply, :ok, socket}
  end

  def handle_info(:after_join, socket) do
    state = socket.assigns[:pid] |> Collusions.Server.get_state
    push socket, "collusion:state", state
    {:noreply, socket}
  end
end
