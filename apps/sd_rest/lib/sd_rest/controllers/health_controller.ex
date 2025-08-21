defmodule SDRest.HealthController do
  use SDRest, :controller

  # GET /api/v1/tenants?limit=25&offset=0
  def show(conn, _params) do
    json(conn, %{
      "status" => "ok"
    })
  end
end
