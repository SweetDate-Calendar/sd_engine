defmodule CLPWeb.TierLive.Index do
  use CLPWeb, :live_view

  alias CLP.Tiers

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Tiers
        <:actions>
          <.button variant="primary" navigate={~p"/tiers/new"}>
            <.icon name="hero-plus" /> New Tier
          </.button>
        </:actions>
      </.header>

      <.table
        id="tiers"
        rows={@streams.tiers}
        row_click={fn {_id, tier} -> JS.navigate(~p"/tiers/#{tier}") end}
      >
        <:col :let={{_id, tier}} label="Name">{tier.name}</:col>
        <:action :let={{_id, tier}}>
          <div class="sr-only">
            <.link navigate={~p"/tiers/#{tier}"}>Show</.link>
          </div>
          <.link navigate={~p"/tiers/#{tier}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, tier}}>
          <.link
            phx-click={JS.push("delete", value: %{id: tier.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Tiers")
     |> stream(:tiers, Tiers.list_tiers())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tier = Tiers.get_tier!(id)
    {:ok, _} = Tiers.delete_tier(tier)

    {:noreply, stream_delete(socket, :tiers, tier)}
  end
end
