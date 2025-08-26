defmodule SDWeb.CalendarLive.Form do
  use SDWeb, :live_view

  alias SD.SweetDate
  alias SD.SweetDate.Calendar

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@page_title}</.header>

      <.form for={@form} id="calendar-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:color_theme]} type="text" label="Color theme" />
        <.input field={@form[:visibility]} type="text" label="Visibility" />

        <footer class="mt-4 flex gap-4">
          <.button phx-disable-with="Saving..." variant="primary">Save Calendar</.button>
          <.link navigate={return_path(@return_to, @calendar)}>Cancel</.link>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, Map.get(params, "return_to", "index"))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    calendar = SweetDate.get_calendar(id)

    socket
    |> assign(:page_title, "Edit Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(SweetDate.change_calendar(calendar)))
  end

  defp apply_action(socket, :new, _params) do
    calendar = %Calendar{}

    socket
    |> assign(:page_title, "New Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(SweetDate.change_calendar(calendar)))
  end

  @impl true
  def handle_event("validate", %{"calendar" => calendar_params}, socket) do
    changeset = SweetDate.change_calendar(socket.assigns.calendar, calendar_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"calendar" => calendar_params}, socket) do
    save_calendar(socket, socket.assigns.live_action, calendar_params)
  end

  defp save_calendar(socket, :new, calendar_params) do
    case SweetDate.create_calendar(calendar_params) do
      {:ok, calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, calendar))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_calendar(socket, :edit, calendar_params) do
    case SweetDate.update_calendar(socket.assigns.calendar, calendar_params) do
      {:ok, calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, calendar))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("show", calendar), do: ~p"/calendars/#{calendar}"
  defp return_path("index", _), do: ~p"/calendars"
  defp return_path(_, _), do: ~p"/calendars"
end
