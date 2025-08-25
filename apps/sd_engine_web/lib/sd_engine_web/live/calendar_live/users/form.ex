defmodule SDWeb.Users.CalendarLive.Form do
  alias SD.Users
  use SDWeb, :live_view

  alias SD.SweetDate
  alias SD.SweetDate.Calendar

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>

      <.form for={@form} id="calendar-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:color_theme]} type="text" label="Color theme" />
        <.input field={@form[:visibility]} type="text" label="Visibility" />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Calendar</.button>
          <.button navigate={return_path(@return_to, @user_id, @return_to_id)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"user_id" => user_id} = params, _session, socket) do
    {:ok,
     socket
     |> assign(return_to_id: return_to_id(params))
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:user_id, user_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to_id(params) do
    case params["return_to"] do
      "show_calendar" ->
        params["id"]

      _ ->
        params["user_id"]
    end
  end

  defp return_to("show_user"), do: "show_user"
  defp return_to(_), do: "show_calendar"

  # Edit mode: load an existing calendar
  defp apply_action(socket, :edit, %{"id" => id}) do
    calendar = SweetDate.get_calendar(id)

    socket
    |> assign(:page_title, "Edit Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(SweetDate.change_calendar(calendar)))
  end

  # New mode: prepare a blank calendar struct with user_id
  defp apply_action(socket, :new, %{"user_id" => user_id}) do
    calendar = %Calendar{}

    socket
    |> assign(:page_title, "New Calendar")
    |> assign(:calendar, calendar)
    |> assign(:form, to_form(SweetDate.change_calendar(calendar, %{user_id: user_id})))
  end

  # Save new
  defp save_calendar(socket, :new, calendar_params) do
    case Users.add_calendar(socket.assigns.user_id, calendar_params) do
      # NEW simpler shape from add_calendar_for/4:
      {:ok, %SD.SweetDate.Calendar{} = _calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar created successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.return_to,
               nil,
               socket.assigns.user_id
             )
         )}

      {:error, _failed_op, %Ecto.Changeset{} = changeset, _changes_so_far} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # Save updates
  defp save_calendar(socket, :edit, calendar_params) do
    case SweetDate.update_calendar(socket.assigns.calendar, calendar_params) do
      {:ok, _calendar} ->
        {:noreply,
         socket
         |> put_flash(:info, "Calendar updated successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.return_to,
               socket.assigns.user_id,
               socket.assigns.return_to_id
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
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

  # Save new

  # Return paths
  defp return_path("show_user", _, user_id) do
    ~p"/users/#{user_id}"
  end

  defp return_path("show_calendar", user_id, calendar_id) do
    ~p"/users/#{user_id}/calendars/#{calendar_id}"
  end
end
