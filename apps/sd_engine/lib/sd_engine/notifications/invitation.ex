defmodule SD.Notifications.Invitation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_invitations" do
    field :status, Ecto.Enum,
      values: [:pending, :accepted, :declined, :maybe, :cancelled, :expired],
      default: :pending

    field :role, Ecto.Enum,
      values: [:organizer, :attendee, :guest],
      default: :attendee

    field :token, :string
    field :expires_at, :utc_datetime
    belongs_to :event, SD.SweetDate.Event, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(invitation, attrs) do
    invitation
    |> cast(attrs, [:status, :role, :token, :expires_at, :event_id])
    |> validate_required([:status, :role, :token, :expires_at, :event_id])
  end
end
