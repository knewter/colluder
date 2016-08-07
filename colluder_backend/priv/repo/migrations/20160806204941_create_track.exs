defmodule ColluderBackend.Repo.Migrations.CreateTrack do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :slots, {:array, :map}, default: []
      add :song_id, references(:songs, on_delete: :nothing)

      timestamps()
    end
    create index(:tracks, [:song_id])

  end
end
