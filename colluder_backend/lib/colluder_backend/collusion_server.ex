defmodule ColluderBackend.CollusionServer do
  use GenServer
  alias ColluderBackend.Collusion.Song

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

  @spec get_slot(pid(), non_neg_integer(), non_neg_integer()) :: true | false
  def get_slot(pid, track_num, slot) do
    GenServer.call(pid, {:get_slot, track_num, slot})
  end

  @spec set_slot(pid(), non_neg_integer(), non_neg_integer(), true | false) :: :ok
  def set_slot(pid, track_num, slot, val) do
    GenServer.cast(pid, {:set_slot, track_num, slot, val})
  end

  def add_track(pid) do
    GenServer.cast(pid, :add_track)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  ### Server API
  def init(id) do
    {:ok, Song.init(id)}
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
        [] -> 0

        _ ->
          state.tracks[0].slots |> Map.keys |> length
      end
    {:reply, count, state}
  end
  def handle_call({:get_slot, track_num, slot}, _from, state) do
    slot_value = state.tracks[track_num].slots[slot]
    {:reply, slot_value, state}
  end
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:add_track, state) do
    next_num = get_track_count(state)
    {:noreply, put_in(state, [:tracks, next_num], Song.initial_track())}
  end
  def handle_cast({:set_slot, track_num, slot, val}, state) do
    {:noreply, put_in(state, [:tracks, track_num, :slots, slot], val)}
  end

  defp get_track_count(state) do
    length(Map.keys(state.tracks))
  end
end
