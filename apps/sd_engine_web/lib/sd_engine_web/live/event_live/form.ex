defmodule SDWeb.EventLive.Form do
  use SDWeb, :live_view
  alias SD.Events
  alias SD.Events.Event

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <br />
      </.header>
      <.form for={@form} id="event-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:color_theme]} type="text" label="Color theme" />
        <.input field={@form[:visibility]} type="text" label="Visibility" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:start_time]} type="datetime-local" label="Start time" />
        <.input field={@form[:end_time]} type="datetime-local" label="End time" />
        <.input field={@form[:recurrence_rule]} type="text" label="Recurrence rule" />
        <.input field={@form[:all_day]} type="checkbox" label="All day" />
        <.input field={@form[:calendar_id]} type="text" class="hidden" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Event</.button>
          <.button navigate={@return_to}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  defp return_path(return_to) do
    case URI.parse(return_to) do
      %URI{path: path, query: nil} -> path
      %URI{path: path, query: query} -> "#{path}?#{query}"
    end
  end

  @impl true
  def mount(
        %{"calendar_id" => calendar_id, "return_to" => return_to} = params,
        _session,
        socket
      ) do
    {:ok,
     socket
     |> assign(:return_to, return_path(return_to))
     |> assign(:calendar_id, calendar_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Events.get_event(id)

    socket
    |> assign(:page_title, "Edit Event ID: #{id}")
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(event)))
  end

  defp apply_action(socket, :new, %{"calendar_id" => calendar_id}) do
    event = %Event{calendar_id: calendar_id}

    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(event)))
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset = Events.change_event(socket.assigns.event, event_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.live_action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    case Events.update_event(socket.assigns.event, event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Events.create_event(event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
