defmodule SDTCP.Handlers.Helpers do
  @moduledoc false

  def format_errors(errors) do
    for {field, {msg, _meta}} <- errors do
      "#{field} #{msg}"
    end
  end
end
