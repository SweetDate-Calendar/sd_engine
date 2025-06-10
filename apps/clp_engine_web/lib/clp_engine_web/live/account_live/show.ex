defmodule CLPWeb.AccountLive.Show do
  use CLPWeb, :live_view

  alias CLP.Accounts

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
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@account.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Account")
     |> assign(:account, Accounts.get_account!(id))}
  end
end
