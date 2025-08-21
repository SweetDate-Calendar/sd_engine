# apps/sd_rest/lib/sd_rest/error_json.ex
defmodule SDRest.ErrorJSON do
  @moduledoc false

  # Explicit codes you care about in tests
  def render("404.json", _assigns), do: %{errors: %{detail: "Not Found"}}
  def render("500.json", _assigns), do: %{errors: %{detail: "Internal Server Error"}}

  # Optional common codes
  def render("401.json", _assigns), do: %{errors: %{detail: "Unauthorized"}}

  def render("422.json", assigns) do
    # If you pass changeset errors, you can render them here. For now keep generic.
    msg = Map.get(assigns, :message, "Unprocessable Entity")
    %{errors: %{detail: msg}}
  end

  # Fallback for any other template name like "400.json", "403.json", etc.
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
