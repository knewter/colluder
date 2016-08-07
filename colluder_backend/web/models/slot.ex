defmodule Slot do
  use ColluderBackend.Web, :model

  embedded_schema do
    field :enabled
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
