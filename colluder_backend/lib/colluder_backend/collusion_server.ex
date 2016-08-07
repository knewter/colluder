defmodule ColluderBackend.CollusionServer do
  use GenServer

  ### Public API
  def start_link(id) do
    case :global.whereis_name(id) do
      :undefined ->
        GenServer.start_link(__MODULE__, id, name: {:global, id})
      pid ->
        {:ok, pid}
    end
  end

  def tracks(pid) do
    GenServer.call(pid, :tracks)
  end

  def track_count(pid) do
    GenServer.call(pid, :track_count)
  end

  def total_slots(pid) do
    GenServer.call(pid, :total_slots)
  end

  def get_slot(pid, track_num, slot) do
    GenServer.call(pid, {:get_slot, track_num, slot})
  end

  def set_slot(pid, track_num, slot, val) do
    GenServer.cast(pid, {:set_slot, track_num, slot, val})
  end

  def add_track(pid) do
    GenServer.cast(pid, :add_track)
  end

  ### Server API
  def init(id) do
    {:ok, initial_model(id)}
  end

  def handle_call(:tracks, _from, state) do
    {:reply, state.tracks, state}
  end
  def handle_call(:track_count, _from, state) do
    {:reply, get_track_count(state), state}
  end
  def handle_call(:total_slots, _from, state) do
    count =
      case state.tracks |> Map.keys do
        0 -> 0

        _ ->
          state.tracks[0].slots |> Map.keys |> length
      end
    {:reply, count, state}
  end
  def handle_call({:get_slot, track_num, slot}, _from, state) do
    slot_value = state.tracks[track_num].slots[slot]
    {:reply, slot_value, state}
  end

  def handle_cast(:add_track, state) do
    next_num = get_track_count(state)
    {:noreply, put_in(state, [:tracks, next_num], initial_track)}
  end
  def handle_cast({:set_slot, track_num, slot, val}, state) do
    {:noreply, put_in(state, [:tracks, track_num, :slots, slot], val)}
  end

  ### Internal
  defp initial_model(id) do
    %{
      id: id,
      tracks: initial_tracks
    }
  end

  defp initial_tracks do
    %{
      0 => initial_track,
      1 => initial_track
    }
  end

  defp initial_track do
    %{
      slots: initial_slots
    }
  end

  defp initial_slots do
    for i <- (0..19), into: %{} do
      {i, false}
    end
  end
  defp get_track_count(state) do
    length(Map.keys(state.tracks))
  end
end
