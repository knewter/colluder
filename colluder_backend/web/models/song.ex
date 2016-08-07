defmodule ColluderBackend.Song do
  use ColluderBackend.Web, :model

  schema "songs" do
    timestamps()
    has_many :tracks, Track
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> cast_assoc(:tracks)
    |> validate_required([])
  end
end
