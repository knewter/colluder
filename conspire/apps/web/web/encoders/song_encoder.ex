defimpl Poison.Encoder, for: Collusions.Song do
  def encode(%{id: id, tracks: tracks}, _options) do
    %{
      id: id,
      tracks: stringify_track_keys(tracks)
    } |> Poison.encode!
  end

  defp stringify_track_keys(tracks) do
    for {track_id, track} <- tracks, into: %{} do
      {"#{track_id}", stringify_slot_keys(track)}
    end
  end

  defp stringify_slot_keys(track) do
    slots =
      for {k, v} <- track.slots, into: %{} do
        {"#{k}", v}
      end

    %{ slots: slots }
  end
end
