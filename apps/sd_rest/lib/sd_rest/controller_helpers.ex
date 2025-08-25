defmodule SDRest.ControllerHelpers do
  @moduledoc """
  Common utilities for REST controllers: UUID checks, pagination parsing,
  integer coercion/clamping, and basic changeset error translation.

  Use in a controller with:

      use SDRest.ControllerHelpers
      # or
      use SDRest.ControllerHelpers, default_limit: 50, max_limit: 500
  """

  # -- Public API (callable directly or via the macro-generated wrappers) --

  def ensure_uuid(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> :ok
      :error -> :error
    end
  end

  def pagination(params, default_limit, max_limit) do
    limit =
      params
      |> Map.get("limit")
      |> parse_int(default_limit)
      |> clamp(1, max_limit)

    offset =
      params
      |> Map.get("offset")
      |> parse_int(0)
      |> max(0)

    {limit, offset}
  end

  def parse_int(nil, default), do: default
  def parse_int(v, _default) when is_integer(v), do: v

  def parse_int(v, default) when is_binary(v) do
    case Integer.parse(v) do
      {i, _} -> i
      :error -> default
    end
  end

  def clamp(i, min, max) when is_integer(i), do: i |> max(min) |> min(max)

  def translate_changeset_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {k, v}, acc ->
        String.replace(acc, "%{#{k}}", to_string(v))
      end)
    end)
  end

  # -- Macro sugar: injects @default_limit/@max_limit and a local pagination/1 --

  defmacro __using__(opts \\ []) do
    default_limit = Keyword.get(opts, :default_limit, 25)
    max_limit = Keyword.get(opts, :max_limit, 100)

    quote do
      @default_limit unquote(default_limit)
      @max_limit unquote(max_limit)

      import SDRest.ControllerHelpers,
        only: [ensure_uuid: 1, translate_changeset_errors: 1, parse_int: 2, clamp: 3]

      # Local pagination/1 that closes over @default_limit/@max_limit
      defp pagination(params),
        do: SDRest.ControllerHelpers.pagination(params, @default_limit, @max_limit)

      # If you  want parse_int/clamp locally, uncomment these:
      # import SDRest.ControllerHelpers, only: [parse_int: 2, clamp: 3]
    end
  end
end
