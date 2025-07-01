defmodule CLPWeb.AccountLive.Show do
  use CLPWeb, :live_view

  alias CLP.Accounts
  alias CLP.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Account {@account.id}
        <:subtitle>This is a account record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/accounts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/accounts/#{@account}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit account
          </.button>

          <.button variant="primary" navigate={~p"/accounts/#{@account}/tiers/new"}>
            <.icon name="hero-plus" /> New Tier
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@account.name}</:item>
      </.list>
      Tiers
      <.table
        id="tiers"
        rows={@streams.tiers}
        row_click={fn {_id, tier} -> JS.navigate(~p"/accounts/#{@account}/tiers/#{tier}") end}
      >
        <:col :let={{_id, tier}} label="Name">{tier.name}</:col>
        <:action :let={{_id, tier}}>
          <div class="sr-only">
            <.link navigate={~p"/accounts/#{tier.account_id}/tiers/#{tier}"}>Show</.link>
          </div>
          <.link navigate={~p"/accounts/#{tier.account_id}/tiers/#{tier}/edit?return_to=show"}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, tier}}>
          <.link
            phx-click={JS.push("delete_tier", value: %{tier_id: tier.id}) |> hide("##{id}")}
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
  def mount(%{"id" => id}, _session, socket) do
    account = Accounts.get_account(id) |> Repo.preload(:tiers)

    {:ok,
     socket
     |> assign(:page_title, "Show Account")
     |> stream(:tiers, account.tiers)
     |> assign(:account, account)}
  end

  @impl true
  def handle_event("delete_tier", %{"tier_id" => tier_id}, socket) do
    tier = CLP.Tiers.get_tier(tier_id)
    {:ok, _} = CLP.Tiers.delete_tier(tier)

    {:noreply, stream_delete(socket, :tiers, tier)}
  end
end
