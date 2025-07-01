defmodule CLPWeb.AccountLive.Index do
  use CLPWeb, :live_view

  alias CLP.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Accounts
        <:actions>
          <.button variant="primary" navigate={~p"/accounts/new"}>
            <.icon name="hero-plus" /> New Account
          </.button>
        </:actions>
      </.header>

      <.table
        id="accounts"
        rows={@streams.accounts}
        row_click={fn {_id, account} -> JS.navigate(~p"/accounts/#{account}") end}
      >
        <:col :let={{_id, account}} label="Name">{account.name}</:col>
        <:action :let={{_id, account}}>
          <div class="sr-only">
            <.link navigate={~p"/accounts/#{account}"}>Show</.link>
          </div>
          <.link navigate={~p"/accounts/#{account}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, account}}>
          <.link
            phx-click={JS.push("delete", value: %{id: account.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Accounts")
     |> stream(:accounts, Accounts.list_accounts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounts.get_account(id)
    {:ok, _} = Accounts.delete_account(account)

    {:noreply, stream_delete(socket, :accounts, account)}
  end
end
