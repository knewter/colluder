defmodule Conspire.Web.CollusionChannel do
  use Conspire.Web.Web, :channel
  @refresh_rate 1_000 # TODO: Tune?

  def join("collusion:"<>id, _payload, socket) do
    {:ok, pid} = Collusions.Supervisor.start_collusion(id)
    send(self, :push_state)
    {
      :ok,
      socket
        |> Phoenix.Socket.assign(:id, id)
        |> Phoenix.Socket.assign(:pid, pid)
    }
  end

  def handle_in("track:add", _, socket) do
    :ok = socket.assigns[:pid] |> Collusions.Server.add_track
    broadcast_state(socket)
    {:reply, :ok, socket}
  end

  def handle_in("note:check", msg, socket) do
    IO.inspect msg
    :ok = socket.assigns[:pid] |> Collusions.Server.set_slot(msg["trackId"], msg["slotId"], msg["on"])
    broadcast_state(socket)
    {:reply, :ok, socket}
  end

  def handle_in("note:set", msg, socket) do
    IO.inspect msg
    :ok = socket.assigns[:pid] |> Collusions.Server.set_note(msg["trackId"], msg["noteId"])
    broadcast_state(socket)
    {:reply, :ok, socket}
  end

  def handle_info(:push_state, socket) do
    :timer.send_after(@refresh_rate, :push_state)
    push_state(socket)
    {:noreply, socket}
  end

  def push_state(socket) do
    state = socket.assigns[:pid] |> Collusions.Server.get_state
    push socket, "collusion:state", state
  end

  def broadcast_state(socket) do
    state = socket.assigns[:pid] |> Collusions.Server.get_state
    broadcast! socket, "collusion:state", state
  end
end
