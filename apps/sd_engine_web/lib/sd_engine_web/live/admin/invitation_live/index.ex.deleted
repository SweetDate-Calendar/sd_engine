defmodule SDWeb.Admin.InvitationLive.Index do
  use SDWeb, :live_view

  alias SD.Notifications

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Event invitations
        <:actions>
          <.button variant="primary" navigate={~p"/events/#{@event_id}/event_invitations/new"}>
            <.icon name="hero-plus" /> New Invitation
          </.button>
        </:actions>
      </.header>

      <.table
        id="event_invitations"
        rows={@streams.event_invitations}
        row_click={fn {_id, invitation} -> JS.navigate(~p"/events/#{@event_id}/event_invitations/#{invitation}") end}
      >
        <:col :let={{_id, invitation}} label="Status">{invitation.status}</:col>
        <:col :let={{_id, invitation}} label="Role">{invitation.role}</:col>
        <:col :let={{_id, invitation}} label="Token">{invitation.token}</:col>
        <:col :let={{_id, invitation}} label="Expires at">{invitation.expires_at}</:col>
        <:action :let={{_id, invitation}}>
          <div class="sr-only">
            <.link navigate={~p"/events/#{@event_id}/event_invitations/#{invitation}"}>Show</.link>
          </div>
          <.link navigate={~p"/events/#{@event_id}/event_invitations/#{invitation}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, invitation}}>
          <.link
            phx-click={JS.push("delete", value: %{id: invitation.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"event_id" => event_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Event invitations")
     |> stream(:event_invitations, Notifications.list_event_invitations(event_id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invitation = Notifications.get_invitation(id)
    {:ok, _} = Notifications.delete_invitation(invitation)

    {:noreply, stream_delete(socket, :event_invitations, invitation)}
  end
end
