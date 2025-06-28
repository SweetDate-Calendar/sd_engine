defmodule CLPWeb.TierLive.Show do
  use CLPWeb, :live_view

  alias CLP.Tiers

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Tier {@tier.id}
        <:subtitle>This is a tier record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/tiers"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/tiers/#{@tier}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit tier
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@tier.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Tier")
     |> assign(:tier, Tiers.get_tier!(id))}
  end
end
