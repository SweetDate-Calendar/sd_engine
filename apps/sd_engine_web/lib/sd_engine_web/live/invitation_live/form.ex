defmodule SDWeb.InvitationLive.Form do
  use SDWeb, :live_view

  alias SD.Invitations
  alias SD.Invitations.Invitation

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage invitation records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="invitation-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:role]} type="text" label="Role" />
        <.input field={@form[:token]} type="text" label="Token" />
        <.input field={@form[:expires_at]} type="datetime-local" label="Expires at" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Invitation</.button>
          <.button navigate={return_path(@return_to, @invitation)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    invitation = Invitations.get_invitation!(id)

    socket
    |> assign(:page_title, "Edit Invitation")
    |> assign(:invitation, invitation)
    |> assign(:form, to_form(Invitations.change_invitation(invitation)))
  end

  defp apply_action(socket, :new, _params) do
    invitation = %Invitation{}

    socket
    |> assign(:page_title, "New Invitation")
    |> assign(:invitation, invitation)
    |> assign(:form, to_form(Invitations.change_invitation(invitation)))
  end

  @impl true
  def handle_event("validate", %{"invitation" => invitation_params}, socket) do
    changeset = Invitations.change_invitation(socket.assigns.invitation, invitation_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"invitation" => invitation_params}, socket) do
    save_invitation(socket, socket.assigns.live_action, invitation_params)
  end

  defp save_invitation(socket, :edit, invitation_params) do
    case Invitations.update_invitation(socket.assigns.invitation, invitation_params) do
      {:ok, invitation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, invitation))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_invitation(socket, :new, invitation_params) do
    case Invitations.create_invitation(invitation_params) do
      {:ok, invitation} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invitation created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, invitation))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _invitation), do: ~p"/event_invitations"
  defp return_path("show", invitation), do: ~p"/event_invitations/#{invitation}"
end
