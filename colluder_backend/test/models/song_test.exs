defmodule ColluderBackend.SongTest do
  use ColluderBackend.ModelCase

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Song.changeset(%Song{}, @valid_attrs)
    assert changeset.valid?
  end
end
