defmodule ColluderBackend.Repo.Migrations.CreateSong do
  use Ecto.Migration

  def change do
    create table(:songs) do

      timestamps()
    end

  end
end
