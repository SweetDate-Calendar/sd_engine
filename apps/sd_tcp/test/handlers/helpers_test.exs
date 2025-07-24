defmodule SDTCP.Handlers.HelpersTest do
  use ExUnit.Case, async: true
  alias SDTCP.Handlers.Helpers

  test "formats changeset errors into readable messages" do
    changeset =
      {%{}, %{name: :string, email: :string}}
      |> Ecto.Changeset.cast(%{}, [:name, :email])
      |> Ecto.Changeset.validate_required([:name, :email])

    result = Helpers.format_errors(changeset.errors)
    assert "name can't be blank" in result
    assert "email can't be blank" in result
  end
end
