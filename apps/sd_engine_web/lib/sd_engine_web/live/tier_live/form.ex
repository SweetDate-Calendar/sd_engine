defmodule SDWeb.TierLive.Form do
  use SDWeb, :live_view

  alias SD.Tiers
  alias SD.Tiers.Tier

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
      </.header>
      <%= if @live_action in [:new, :edit] do %>
        <.form for={@form} id="tier-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:account_id]} type="text" class="hidden" />
          <footer>
            <.button phx-disable-with="Saving..." variant="primary">Save Tier</.button>
            <.button navigate={return_path(@return_to, @tier)}>Cancel</.button>
          </footer>
        </.form>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"account_id" => account_id} = params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:account_id, account_id)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show_account"), do: "show_account"
  defp return_to(_), do: "show_tier"

  defp apply_action(socket, :edit, %{"id" => id}) do
    tier = Tiers.get_tier(id) |> SD.Repo.preload(:account)

    socket
    |> assign(:page_title, "Edit Tier")
    |> assign(:tier, tier)
    |> assign(:form, to_form(Tiers.change_tier(tier)))
  end

  defp apply_action(socket, :new, %{"account_id" => account_id}) do
    tier = %Tier{account_id: account_id}

    socket
    |> assign(:page_title, "New Tier")
    |> assign(:tier, tier)
    |> assign(:form, to_form(Tiers.change_tier(tier)))
  end

  @impl true
  def handle_event("validate", %{"tier" => tier_params}, socket) do
    changeset = Tiers.change_tier(socket.assigns.tier, tier_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tier" => tier_params}, socket) do
    save_tier(socket, socket.assigns.live_action, tier_params)
  end

  defp save_tier(socket, :edit, tier_params) do
    case Tiers.update_tier(socket.assigns.tier, tier_params) do
      {:ok, tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tier updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tier))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tier(socket, :new, tier_params) do
    case SD.Accounts.create_tier(tier_params) do
      {:ok, tier} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tier created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, tier))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("show_account", tier) do
    ~p"/accounts/#{tier.account_id}"
  end

  defp return_path("show_tier", tier) do
    ~p"/accounts/#{tier.account_id}/tiers/#{tier}"
  end
end
