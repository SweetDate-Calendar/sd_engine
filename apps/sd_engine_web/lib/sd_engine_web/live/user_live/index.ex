defmodule SDWeb.UserLive.Index do
  use SDWeb, :live_view

  alias SD.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Users
        <:actions>
          <.button variant="primary" navigate={~p"/users/new"}>
            <.icon name="hero-plus" /> New User
          </.button>
        </:actions>
      </.header>

      <.table
        id="users"
        rows={@streams.users}
        row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user}") end}
      >
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:action :let={{_id, user}}>
          <div class="sr-only">
            <.link navigate={~p"/users/#{user}"}>Show</.link>
          </div>
          <.link navigate={~p"/users/#{user}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, user}}>
          <.link
            phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
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
    if connected?(socket), do: SDWeb.Endpoint.subscribe("users")

    {:ok,
     socket
     |> assign(:page_title, "Listing Users")
     |> stream(:users, Accounts.list_users())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{event: "created", payload: %SD.Accounts.User{} = user},
        socket
      ) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "updated", payload: %SD.Accounts.User{} = user},
        socket
      ) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "deleted", payload: %SD.Accounts.User{} = user},
        socket
      ) do
    {:noreply, stream_delete(socket, :users, user)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{event: "pruned"},
        socket
      ) do
    {:noreply,
     socket
     |> stream(:users, [], reset: true)
     |> stream(:users, Accounts.list_users())}
  end
end
