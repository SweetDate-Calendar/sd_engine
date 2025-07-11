defmodule SD.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field :status, Ecto.Enum,
      values: [:scheduled, :cancelled, :postponed, :completed],
      default: :scheduled

    field :name, :string
    field :description, :string
    field :color_theme, :string

    field :visibility, Ecto.Enum,
      values: [:private, :public, :busy],
      default: :public

    field :location, :string
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime

    field :recurrence_rule, Ecto.Enum,
      values: [:none, :daily, :weekly, :monthly, :yearly],
      default: :none

    field :all_day, :boolean, default: false
    belongs_to :calendar, SD.Calendars.Calendar, type: :binary_id

    many_to_many :users, SD.Accounts.User,
      join_through: "event_users",
      on_replace: :delete,
      join_keys: [event_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :status,
      :name,
      :description,
      :color_theme,
      :visibility,
      :location,
      :start_time,
      :end_time,
      :recurrence_rule,
      :all_day
    ])
    |> validate_required([
      :status,
      :name,
      :description,
      :color_theme,
      :visibility,
      :location,
      :start_time,
      :end_time,
      :recurrence_rule,
      :all_day
    ])
  end
end
