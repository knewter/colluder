defmodule ColluderBackend.Collusion.Song do
  def init(id) do
    %{
      id: id,
      tracks: initial_tracks
    }
  end

  def initial_tracks do
    %{
      0 => initial_track,
      1 => initial_track
    }
  end

  def initial_track do
    %{
      slots: initial_slots
    }
  end

  def initial_slots do
    for i <- (0..19), into: %{} do
      {i, false}
    end
  end
end
