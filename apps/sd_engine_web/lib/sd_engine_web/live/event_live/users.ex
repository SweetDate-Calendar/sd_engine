defmodule SDWeb.EventUserLive.Form do
  use SDWeb, :live_view

  alias SD.Calendars
  alias SD.Calendars.EventUser
  alias SD.Accounts
  alias SD.SweetDate

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Event Users
        <:subtitle>Event: {@event.name} - ID: {@event.id}</:subtitle>
        <:actions>
          <.button navigate={~p"/calendars/#{@event.calendar_id}/events/#{@event.id}"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.form for={@form} id="event-user-form" phx-submit="save">
        <.input
          field={@form[:user_id]}
          type="select"
          label="Select User"
          options={@user_options}
        />

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
          <.button phx-disable-with="Assigning..." variant="primary">
            Assign User
          </.button>
          <.button navigate={~p"/events/#{@event.id}"}>Cancel</.button>
        </footer>
      </.form>

      <.header class="mt-14">
        <:subtitle>Users assigned to this event.</:subtitle>
      </.header>

      <.table
        id="event-users"
        rows={@streams.event_users}
        row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user}") end}
      >
        <:col :let={{_id, user}} label="Name">
        <span id={"event-user-name-#{user.id}"}><%= user.name %></span>
        </:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:col :let={{_id, user}} label="Role">
        <%= user.event_users |> hd() |> Map.get(:role) %>
        </:col>
        <:col :let={{_id, user}} label="Status">
        <%= user.event_users |> hd() |> Map.get(:status) %>
        </:col>

        <:action :let={{id, user}}>
        <.link navigate={~p"/events/#{@event.id}/users/#{user.id}/edit"}>
          Edit
        </.link>

        <.link
          phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
          >
            Remove
        </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => event_id}, _session, socket) do
    event =
      SweetDate.get_event(event_id)
      |> SD.Repo.preload(users: [:event_users])

    users = Accounts.list_users()
    user_options = Enum.map(users, fn u -> {u.name, u.id} end)

    changeset =
      EventUser.changeset(%EventUser{}, %{
        event_id: event.id,
        user_id: nil,
        role: :attendee,
        status: :invited
      })

    {:ok,
     socket
     |> assign(:event, event)
     |> assign(:user_options, user_options)
     |> stream(:event_users, event.users)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"event_user" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    case Calendars.create_event_user(params) do
      {:ok, event_user} ->
        event_user = SD.Repo.preload(event_user, user: [:event_users])

        {:noreply,
         socket
         |> put_flash(:info, "User assigned to event successfully")
         |> stream_insert(:event_users, event_user.user)}

      {:error, %Ecto.Changeset{} = changeset} ->
        case changeset.errors do
          [event_id: {"has already been taken", [constraint: :unique, constraint_name: _]}] ->
            {:noreply,
             socket
             |> put_flash(:error, "This user is already assigned to the event")
             |> assign(:form, to_form(changeset))}

          _ ->
            {:noreply, assign(socket, :form, to_form(changeset))}
        end
    end
  end

  def handle_event("delete", %{"id" => user_id}, socket) do
    event_id = socket.assigns.event.id

    case Calendars.get_event_user(event_id, user_id) do
      {:ok, event_user} ->
        {:ok, _} = Calendars.delete_event_user(event_user)

        {:noreply,
         socket
         |> put_flash(:info, "User removed from event successfully")
         |> stream_delete(:event_users, event_user.user)}

      {:error, :not_found} ->
        {:noreply, put_flash(socket, :error, "Event user not found")}
    end
  end
end
