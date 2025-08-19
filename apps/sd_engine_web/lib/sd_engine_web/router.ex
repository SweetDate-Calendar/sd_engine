defmodule SDWeb.Router do
  use SDWeb, :router

  import SDWeb.Plugs.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SDWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  # forward "/api", Elixir.SD_REST.Router

  scope "/", SDWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]
    get "/", PageController, :home
    post "/login", SessionController, :create
  end

  scope "/", SDWeb do
    pipe_through [:browser, :require_authenticated_admin]

    delete "/logout", SessionController, :delete

    live "/calendars/new", Global.CalendarLive.Form, :new
    live "/calendars/:id", Global.CalendarLive.Show, :show
    live "/calendars/:id/edit", Tenants.CalendarLive.Form, :edit

    live "/tenants/:tenant_id/calendars/new", Tenants.CalendarLive.Form, :new
    live "/tenants/:tenant_id/calendars/:id", Tenants.CalendarLive.Show, :show
    live "/tenants/:tenant_id/calendars/:id/edit", Tenants.CalendarLive.Form, :edit

    live "/users/:user_id/calendars/new", Users.CalendarLive.Form, :new
    live "/users/:user_id/calendars/:id", Users.CalendarLive.Show, :show
    live "/users/:user_id/calendars/:id/edit", Tenants.CalendarLive.Form, :edit

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Form, :new
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/edit", UserLive.Form, :edit

    live "/tenants", TenantLive.Index, :index
    live "/tenants/new", TenantLive.Form, :new
    live "/tenants/:id", TenantLive.Show, :show
    live "/tenants/:id/edit", TenantLive.Form, :edit

    # live "/calendars/:calendar_id/events", EventLive.Index, :index
    live "/calendars/:calendar_id/events/new", EventLive.Form, :new
    live "/calendars/:calendar_id/events/:id", EventLive.Show, :show
    live "/calendars/:calendar_id/events/:id/edit", EventLive.Form, :edit

    live "/credentials", CredentialLive.Index, :index
    live "/credentials/new", CredentialLive.Form, :new
    live "/credentials/:id", CredentialLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", SDWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sd_engine_web, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SDWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
