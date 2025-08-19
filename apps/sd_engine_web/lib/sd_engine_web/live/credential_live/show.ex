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
        <:item title="App ID">{@credential.app_id}</:item>
        <:item title="Expires at">{@credential.expires_at}</:item>
        <:item title="Status">{@credential.status}</:item>
        <%!-- <:item title="Last used at">{@credential.last_used_at}</:item> --%>
        <:item title="Created at">{@credential.inserted_at}</:item>
        <:item title="Updated at">{@credential.updated_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "Show Credential")}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    cred = Account.get_credential!(id)
    {:noreply, assign(socket, :credential, cred)}
  end
end
