defmodule SDWeb.CredentialLive.Form do
  use SDWeb, :live_view

  alias SD.Account
  alias SD.Account.Credential

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <%= if @generated do %>
        <!-- Stable container -->
        <div
          id="generated-credentials"
          class="rounded-md border p-4 bg-yellow-50 dark:bg-yellow-900 dark:border-yellow-700 space-y-3"
        >
          <h3 class="font-semibold text-gray-900 dark:text-gray-100">
            This is the only time your SD_APP_SECRET will be shown.
          </h3>
          <p class="text-sm text-gray-700 dark:text-gray-200">
            Please save your SD_APP_ID and SD_APP_SECRET in a secure place.
            You won’t be able to see the secret again, but you can always generate a new credential if needed.
          </p>
          
    <!-- SD_APP_ID -->
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-900 dark:text-gray-100">
              SD_APP_ID
            </label>
            <div class="select-all w-full rounded-md border border-gray-300 bg-gray-50 px-3 py-2 font-mono text-sm text-gray-900
                        dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100">
              {@generated.app_id}
            </div>
          </div>
          
    <!-- SD_APP_SECRET -->
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-900 dark:text-gray-100">
              SD_APP_SECRET
            </label>
            <div class="select-all w-full rounded-md border border-gray-300 bg-gray-50 px-3 py-2 font-mono text-sm text-gray-900
                        dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100">
              {@generated.private_key}
            </div>
          </div>
          
    <!-- Confirm saved -->
          <div class="flex items-center gap-2 mt-2">
            <input
              id="confirm_saved"
              type="checkbox"
              phx-click="toggle_confirm"
              checked={@confirmed_saved}
              class="checkbox checkbox-sm border-2 border-blue-500 text-blue-600 font-bold rounded-md  focus:ring-2 focus:ring-blue-400"
            />

            <label for="confirm_saved" class="text-sm text-gray-900 dark:text-gray-100">
              I confirm I have saved the credentials in a secure place
            </label>
          </div>

          <% json =
            Jason.encode!(%{
              "SD_APP_ID" => @generated.app_id,
              "SD_APP_SECRET" => @generated.private_key
            })

          filename = "sweetdate_credentials_#{@generated.app_id}.json" %>

          <div class="flex flex-wrap gap-2">
            <.button
              phx-click="continue"
              variant="primary"
              class={
                if !@confirmed_saved do
                  "bg-blue-300 text-white cursor-not-allowed"
                else
                  "bg-blue-600 hover:bg-blue-700 text-white"
                end
              }
            >
              Done
            </.button>

            <a
              href={"data:application/json;charset=utf-8,#{URI.encode(json)}"}
              download={filename}
              class="inline-flex items-center rounded-md border px-3 py-2 text-sm
                     border-gray-300 bg-white text-gray-900 hover:bg-gray-50
                     dark:border-gray-700 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700"
            >
              Download credentials (.json)
            </a>
          </div>

          <p class="text-xs text-gray-700 dark:text-gray-300">
            You can copy the values above or download them as a JSON file. We cannot show the secret again.
          </p>
        </div>
      <% else %>
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage credential records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="credential-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:expires_at]} type="datetime-local" label="Expires at (optional)" />
          <footer class="mt-3">
            <.button phx-disable-with="Saving..." variant="primary">Save Credential</.button>
            <.button navigate={return_path(@return_to, @credential)}>Cancel</.button>
          </footer>
        </.form>
      <% end %>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:generated, nil)
     |> assign(:confirmed_saved, false)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :new, _params) do
    credential = %Credential{}

    socket
    |> assign(:page_title, "New Credential")
    |> assign(:credential, credential)
    |> assign(:form, to_form(Account.change_credential(credential)))
  end

  @impl true
  def handle_event("toggle_confirm", _params, socket) do
    {:noreply, update(socket, :confirmed_saved, fn c -> not c end)}
  end

  def handle_event("validate", %{"credential" => credential_params}, socket) do
    changeset = Account.change_credential(socket.assigns.credential, credential_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"credential" => params}, socket) do
    safe_params = Map.take(params, ["expires_at"])

    case SD.Account.generate_credential(safe_params) do
      {:ok, credential, priv} ->
        priv_b64 = Base.url_encode64(priv, padding: false)

        {:noreply,
         socket
         |> put_flash(:info, "Credential created successfully")
         |> assign(:generated, %{
           id: credential.id,
           app_id: credential.app_id,
           private_key: priv_b64
         })
         |> assign(:credential, credential)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("continue", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/credentials")}
  end

  defp return_path("index", _credential), do: ~p"/credentials"
  defp return_path("show", credential), do: ~p"/credentials/#{credential}"
end
