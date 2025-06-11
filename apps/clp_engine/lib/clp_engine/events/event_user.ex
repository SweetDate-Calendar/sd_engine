defmodule CLP.Events.EventUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_users" do
    field :role, Ecto.Enum,
      values: [:organizer, :attendee, :guest],
      default: :attendee

    field :status, Ecto.Enum,
      values: [:invited, :accepted, :declined, :maybe, :cancelled],
      default: :invited

    belongs_to :event, CLP.Events.Event, type: :binary_id
    belongs_to :user, CLP.Accounts.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_user, attrs) do
    event_user
    |> cast(attrs, [:event_id, :user_id, :role, :status])
    |> validate_required([:event_id, :user_id, :role, :status])
    |> unique_constraint([:event_id, :user_id], name: "unique_event_user")
  end
end
