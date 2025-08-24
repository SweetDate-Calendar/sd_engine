defmodule SDRest.ChangesetErrors do
  @moduledoc false

  def to_map(%Ecto.Changeset{} = cs) do
    cs
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, val}, acc ->
        String.replace(acc, "%{#{key}}", safe_val(val))
      end)
    end)
    |> stringify_keys()
  end

  # --- helpers ---

  defp stringify_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {to_string(k), stringify_keys(v)} end)
    |> Enum.into(%{})
  end

  defp stringify_keys(list) when is_list(list), do: Enum.map(list, &stringify_keys/1)
  defp stringify_keys(other), do: other

  defp safe_val(nil), do: ""
  defp safe_val(v) when is_binary(v), do: v
  defp safe_val(v) when is_atom(v), do: Atom.to_string(v)
  defp safe_val(v) when is_integer(v) or is_float(v), do: to_string(v)

  # Turn enum type metadata into a friendly list of allowed values: "owner, admin, guest"
  defp safe_val({:parameterized, {Ecto.Enum, %{mappings: mappings}}}) do
    mappings
    |> Enum.map(fn {atom, _dump} -> Atom.to_string(atom) end)
    |> Enum.join(", ")
  end

  # Fallback: don’t crash on unknown structures
  defp safe_val(other), do: inspect(other)
end
