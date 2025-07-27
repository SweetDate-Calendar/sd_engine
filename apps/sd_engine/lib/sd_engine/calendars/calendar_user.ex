defmodule SD.Calendars.CalendarUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "calendar_users" do
    field :role, Ecto.Enum, values: [:owner, :admin, :guest]

    belongs_to :calendar, SD.Calendars.Calendar, type: :binary_id
    belongs_to :user, SD.Users.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(calendar_user, attrs) do
    calendar_user
    |> cast(attrs, [:role, :calendar_id, :user_id])
    |> validate_required([:role, :calendar_id, :user_id])
    |> unique_constraint([:calendar_id, :user_id],
      name: "calendar_users_calendar_id_user_id_index"
    )
  end
end
