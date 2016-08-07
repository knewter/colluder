defmodule ColluderBackend.Track do
  use ColluderBackend.Web, :model

  schema "tracks" do
    embeds_many :slots, Slot, on_replace: :delete
    belongs_to :song, Song

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> cast_embed(:slots, [])
    |> validate_required([:slots])
  end
end
