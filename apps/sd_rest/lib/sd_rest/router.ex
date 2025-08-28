defmodule SDRest.Router do
  use SDRest, :router

  pipeline :public do
    plug(:accepts, ["json"])
  end

  pipeline :api_auth do
    plug(:accepts, ["json"])
    plug(SDRest.Plugs.SignatureV1, resolver: &SDRest.Auth.Resolver.pubkey/1, skew: 300)
  end

  scope "/api/v1", SDRest do
    pipe_through(:public)
    get("/healthz", HealthController, :show)
  end

  scope "/api/v1", SDRest do
    pipe_through(:api_auth)

    resources "/calendars", CalendarsController do
      resources "/events", EventsController
    end

    resources "/tenants", TenantsController do
      resources "/users", TenantUsersController
      resources "/calendars", TenantSweetDateController
    end

    resources "/users", UsersController do
    end
  end
end
