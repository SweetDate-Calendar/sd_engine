defmodule SDWeb.CredentialLive.Index do
  use SDWeb, :live_view

  alias SD.Account

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Credentials
        <:actions>
          <.button variant="primary" navigate={~p"/credentials/new"}>
            <.icon name="hero-plus" /> New Credential
          </.button>
        </:actions>
      </.header>

      <.table
        id="credentials"
        rows={@streams.credentials}
        row_click={fn {_id, credential} -> JS.navigate(~p"/credentials/#{credential}") end}
      >
        <:col :let={{_id, credential}} label="App">{credential.app_id}</:col>
        <:col :let={{_id, credential}} label="Public key">{credential.public_key}</:col>
        <:col :let={{_id, credential}} label="Alg">{credential.alg}</:col>
        <:col :let={{_id, credential}} label="Status">{credential.status}</:col>
        <:col :let={{_id, credential}} label="Expires at">{credential.expires_at}</:col>
        <:col :let={{_id, credential}} label="Last used at">{credential.last_used_at}</:col>
        <:action :let={{_id, credential}}>
          <div class="sr-only">
            <.link navigate={~p"/credentials/#{credential}"}>Show</.link>
          </div>
        </:action>
        <:action :let={{id, credential}}>
          <.link
            phx-click={JS.push("delete", value: %{id: credential.id}) |> hide("##{id}")}
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
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Credentials")
     |> stream(:credentials, Account.list_credentials())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    credential = Account.get_credential!(id)
    {:ok, _} = Account.delete_credential(credential)

    {:noreply, stream_delete(socket, :credentials, credential)}
  end
end
