defmodule ColluderBackend.TrackTest do
  use ColluderBackend.ModelCase

  alias ColluderBackend.Track

  @slot %{enabled: true}
  @valid_attrs %{slots: [@slot]}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Track.changeset(%Track{}, @valid_attrs)
    assert changeset.valid?
  end
end
