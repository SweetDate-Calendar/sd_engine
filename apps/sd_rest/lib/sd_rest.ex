defmodule SDRest do
  @moduledoc """
  Entry point for SDRest’s web layer (API-only).
  Provides minimal `:router`, `:controller`, and verified routes.
  """

  # Only serve what you actually have in priv/static
  def static_paths, do: ~w(favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      # No LiveView router in API-only app
    end
  end

  # lib/sd_rest.ex
  def controller do
    quote do
      use Phoenix.Controller, formats: [:json]
      import Plug.Conn
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: SDRest.Endpoint,
        router: SDRest.Router,
        statics: SDRest.static_paths()
    end
  end

  @doc false
  defmacro __using__(which) when is_atom(which), do: apply(__MODULE__, which, [])
end
