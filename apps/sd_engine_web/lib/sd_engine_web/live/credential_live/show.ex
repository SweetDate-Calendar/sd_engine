defmodule SDWeb.CredentialLive.Show do
  use SDWeb, :live_view

  alias SD.Account

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Credential {@credential.id}
        <:subtitle>This is a credential record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/credentials"}>
            <.icon name="hero-arrow-left" />
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="App">{@credential.app_id}</:item>
        <:item title="Public key">{@credential.public_key}</:item>
        <:item title="Alg">{@credential.alg}</:item>
        <:item title="Status">{@credential.status}</:item>
        <:item title="Expires at">{@credential.expires_at}</:item>
        <:item title="Last used at">{@credential.last_used_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Credential")
     |> assign(:credential, Account.get_credential!(id))}
  end
end
