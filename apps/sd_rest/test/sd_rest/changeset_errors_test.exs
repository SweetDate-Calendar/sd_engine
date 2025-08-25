defmodule SDRest.ChangesetErrorsTest do
  use SD.DataCase, async: true

  alias SDRest.ChangesetErrors
  alias SD.SweetDate.TenantUser

  describe "to_map/1" do
    test "returns map with messages for enum invalid value (no protocol crash)" do
      attrs = %{
        "tenant_id" => Ecto.UUID.generate(),
        "user_id" => Ecto.UUID.generate(),
        # invalid per Ecto.Enum [:owner, :admin, :guest]
        "role" => "pop-singer"
      }

      cs = TenantUser.changeset(%TenantUser{}, attrs)
      result = ChangesetErrors.to_map(cs)

      # Expect an error on :role and no String.Chars crash on enum metadata
      assert %{"role" => msgs} = result
      assert is_list(msgs)
      assert Enum.any?(msgs, &(&1 =~ "invalid" or &1 =~ "is invalid"))
    end

    test "aggregates multiple field errors (invalid UUIDs)" do
      attrs = %{
        "tenant_id" => "not-a-uuid",
        "user_id" => "also-not-a-uuid",
        "role" => "guest"
      }

      cs = TenantUser.changeset(%TenantUser{}, attrs)
      result = ChangesetErrors.to_map(cs)

      # Depending on your changeset validators, these should be present:
      assert Map.has_key?(result, "tenant_id")
      assert Map.has_key?(result, "user_id")

      assert Enum.any?(result["tenant_id"], &(&1 =~ ~r/invalid|not a valid/i))
      assert Enum.any?(result["user_id"], &(&1 =~ ~r/invalid|not a valid/i))
    end

    test "returns empty map when there are no errors" do
      attrs = %{
        "tenant_id" => Ecto.UUID.generate(),
        "user_id" => Ecto.UUID.generate(),
        "role" => "guest"
      }

      cs =
        %TenantUser{}
        |> TenantUser.changeset(attrs)
        # force no errors to simulate a clean changeset
        |> Map.put(:errors, [])

      assert %{} = ChangesetErrors.to_map(cs)
    end
  end
end
