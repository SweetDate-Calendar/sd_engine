defmodule SDWeb.CredentialLive.Form do
  use SDWeb, :live_view

  alias SD.Account
  alias SD.Account.Credential

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage credential records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="credential-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:app_id]} type="text" label="App" />
        <.input field={@form[:public_key]} type="textarea" label="Public key" />
        <.input field={@form[:alg]} type="text" label="Alg" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input field={@form[:expires_at]} type="text" label="Expires at" />
        <.input field={@form[:last_used_at]} type="text" label="Last used at" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Credential</.button>
          <.button navigate={return_path(@return_to, @credential)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    credential = Account.get_credential!(id)

    socket
    |> assign(:page_title, "Edit Credential")
    |> assign(:credential, credential)
    |> assign(:form, to_form(Account.change_credential(credential)))
  end

  defp apply_action(socket, :new, _params) do
    credential = %Credential{}

    socket
    |> assign(:page_title, "New Credential")
    |> assign(:credential, credential)
    |> assign(:form, to_form(Account.change_credential(credential)))
  end

  @impl true
  def handle_event("validate", %{"credential" => credential_params}, socket) do
    changeset = Account.change_credential(socket.assigns.credential, credential_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"credential" => credential_params}, socket) do
    save_credential(socket, socket.assigns.live_action, credential_params)
  end

  defp save_credential(socket, :edit, credential_params) do
    case Account.update_credential(socket.assigns.credential, credential_params) do
      {:ok, credential} ->
        {:noreply,
         socket
         |> put_flash(:info, "Credential updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, credential))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_credential(socket, :new, credential_params) do
    case Account.create_credential(credential_params) do
      {:ok, credential} ->
        {:noreply,
         socket
         |> put_flash(:info, "Credential created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, credential))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _credential), do: ~p"/credentials"
  defp return_path("show", credential), do: ~p"/credentials/#{credential}"
end
