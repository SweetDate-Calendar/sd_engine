defmodule CLP.Calendars.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "calendars" do
    field :name, :string
    field :color_theme, :string
    field :visibility, :string
    field :account_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:name, :color_theme, :visibility])
    |> validate_required([:name, :color_theme, :visibility])
  end
end
