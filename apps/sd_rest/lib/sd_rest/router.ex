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

  # if Mix.env() in [:dev, :test] do
  scope "/api/v1/test", SDRest do
    post "/prune", TestController, :prune
    post "/seed", TestController, :seed
  end

  # end

  scope "/api/v1", SDRest do
    pipe_through(:api_auth)

    resources "/calendars", CalendarsController do
      resources "/events", EventsController
    end

    resources "/tenants", TenantsController

    resources "/users", UsersController do
      resources "/calendars", CalendarsController
    end
  end

  scope "/api/v1/join", SDRest.Join do
    pipe_through(:api_auth)
    resources "/tenant_calendars", TenantCalendarsController, only: [:create, :delete]
    resources "/tenant_users", TenantUsersController, only: [:create, :update, :delete]

    resources "/calendars", CalendarController, only: [] do
      resources "/users", CalendarUsersController, only: [:create, :update, :delete]
    end

    resources "/event_users", EventUsersController, only: [:create, :update, :delete]
  end
end
