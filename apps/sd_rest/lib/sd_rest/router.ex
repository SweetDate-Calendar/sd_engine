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

    get("/tenants", TenantsController, :index)
    post("/tenants", TenantsController, :create)
    get("/tenants/:id", TenantsController, :show)
    put("/tenants/:id", TenantsController, :update)
    delete("/tenants/:id", TenantsController, :delete)

    resources "/tenants", TenantsController, only: [] do
      resources "/users", TenantUsersController, only: [:index, :create, :show, :update, :delete]
    end
  end
end
