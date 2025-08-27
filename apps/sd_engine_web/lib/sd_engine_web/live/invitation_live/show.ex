defmodule SDWeb.InvitationLive.Show do
  use SDWeb, :live_view

  alias SD.Invitations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Invitation {@invitation.id}
        <:subtitle>This is a invitation record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/event_invitations"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/event_invitations/#{@invitation}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit invitation
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Status">{@invitation.status}</:item>
        <:item title="Role">{@invitation.role}</:item>
        <:item title="Token">{@invitation.token}</:item>
        <:item title="Expires at">{@invitation.expires_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Invitation")
     |> assign(:invitation, Invitations.get_invitation!(id))}
  end
end
