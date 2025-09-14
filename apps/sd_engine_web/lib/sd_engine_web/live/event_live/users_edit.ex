defmodule SDWeb.EventUserEditLive.Form do
  use SDWeb, :live_view
  alias SD.Calendars
  alias SD.Calendars.EventUser
  alias SD.SweetDate

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Edit Event User
        <:subtitle>User: {@user.name} (#{@user.email})</:subtitle>
        <:actions>
          <.button navigate={~p"/events/#{@event.id}/users"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="event-user-edit-form" phx-submit="save">
        <.input
          field={@form[:role]}
          type="select"
          label="Role"
          options={[
            {"Organizer", :organizer},
            {"Attendee", :attendee},
            {"Guest", :guest}
          ]}
        />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[
            {"Invited", :invited},
            {"Accepted", :accepted},
            {"Declined", :declined},
            {"Maybe", :maybe},
            {"Cancelled", :cancelled}
          ]}
        />

        <footer>
          <.button phx-disable-with="Updating..." variant="primary">
            Update
          </.button>
          <.button navigate={~p"/events/#{@event.id}/users"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"event_id" => event_id, "user_id" => user_id}, _session, socket) do
    event = SweetDate.get_event(event_id)
    {:ok, event_user} = Calendars.get_event_user(event_id, user_id)
    user = SD.Repo.preload(event_user, :user).user

    changeset = EventUser.changeset(event_user, %{})

    {:ok,
     socket
     |> assign(:event, event)
     |> assign(:event_user, event_user)
     |> assign(:user, user)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"event_user" => params}, socket) do
    case Calendars.update_event_user(socket.assigns.event_user, params) do
      {:ok, _event_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event user updated successfully")
         |> push_navigate(to: ~p"/events/#{socket.assigns.event.id}/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
