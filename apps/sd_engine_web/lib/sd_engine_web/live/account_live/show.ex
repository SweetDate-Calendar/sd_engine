defmodule SDWeb.AccountLive.Show do
  use SDWeb, :live_view

  alias SD.Accounts
  alias SD.Repo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Name: {@account.name}
        <:actions>
          <.button navigate={~p"/accounts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            id="edit-account-btn"
            navigate={~p"/accounts/#{@account}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit account
          </.button>

          <.button
            variant="primary"
            navigate={~p"/accounts/#{@account}/tiers/new?return_to=show_account"}
          >
            <.icon name="hero-plus" /> New Tier
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="API ID">{@account.id}</:item>
        <:item title="API Secret">{@account.api_secret}</:item>
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
          <.link
            id={"edit-tier-#{tier.id}"}
            navigate={~p"/accounts/#{tier.account_id}/tiers/#{tier}/edit?return_to=show_account"}
          >
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
    tier = SD.Tiers.get_tier(tier_id)
    {:ok, _} = SD.Tiers.delete_tier(tier)

    {:noreply, stream_delete(socket, :tiers, tier)}
  end
end
