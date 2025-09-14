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

  def ensure_uuid(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> :ok
      :error -> :error
    end
  end

  # def validate_uuid_fields(params, fields) do
  #   Enum.reduce(fields, %{}, fn field, acc ->
  #     value = Map.get(params, field)

  #     case ensure_uuid(value) do
  #       :ok -> acc
  #       :error -> Map.put(acc, field, ["is invalid"])
  #     end
  #   end)
  # end

  # def validate_uuid_or_422!(conn, params, required_fields) do
  #   errors = validate_uuid_fields(params, required_fields)

  #   if map_size(errors) > 0 do
  #     conn
  #     |> Plug.Conn.put_status(:unprocessable_entity)
  #     |> Phoenix.Controller.json(%{
  #       "status" => "error",
  #       "message" => "invalid input",
  #       "error_code" => "VALIDATION_ERROR",
  #       "fields" => errors
  #     })
  #     |> Plug.Conn.halt()
  #   else
  #     conn
  #   end
  # end

  # -- Macro sugar: injects @default_limit/@max_limit and a local pagination/1 --

  defmacro __using__(opts \\ []) do
    default_limit = Keyword.get(opts, :default_limit, 25)
    max_limit = Keyword.get(opts, :max_limit, 100)

    quote do
      @default_limit unquote(default_limit)
      @max_limit unquote(max_limit)

      import SDRest.ControllerHelpers,
        only: [
          ensure_uuid: 1,
          translate_changeset_errors: 1,
          parse_int: 2,
          clamp: 3
        ]

      # Local pagination/1 that closes over @default_limit/@max_limit
      defp pagination(params),
        do: SDRest.ControllerHelpers.pagination(params, @default_limit, @max_limit)
    end
  end
end
