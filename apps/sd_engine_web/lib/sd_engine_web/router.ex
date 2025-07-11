defmodule CLPWeb.Router do
  use CLPWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CLPWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CLPWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/accounts", AccountLive.Index, :index
    live "/accounts/new", AccountLive.Form, :new
    live "/accounts/:id", AccountLive.Show, :show
    live "/accounts/:id/edit", AccountLive.Form, :edit
    live "/accounts/:account_id/tiers/new", TierLive.Form, :new
    live "/accounts/:account_id/tiers/:id", TierLive.Show, :show
    live "/accounts/:account_id/tiers/:id/edit", TierLive.Form, :edit

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Form, :new
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/edit", UserLive.Form, :edit

    # live "/tiers/:tier_id/calendars", CalendarLive.Index, :index
    live "/tiers/:tier_id/calendars/new", CalendarLive.Form, :new
    live "/tiers/:tier_id/calendars/:id", CalendarLive.Show, :show
    live "/tiers/:tier_id/calendars/:id/edit", CalendarLive.Form, :edit

    live "/events", EventLive.Index, :index
    live "/events/new", EventLive.Form, :new
    live "/events/:id", EventLive.Show, :show
    live "/events/:id/edit", EventLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", CLPWeb do
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

      live_dashboard "/dashboard", metrics: CLPWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
