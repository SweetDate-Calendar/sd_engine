defmodule SD.AccountsTest do
  use SD.DataCase, async: true

  alias SD.Accounts
  alias SD.Accounts.User

  import SD.AccountsFixtures

  @valid_attrs %{
    name: "Alice",
    email: "alice@example.com"
  }

  @update_attrs %{
    name: "Alice Updated",
    email: "alice.updated@example.com"
  }

  @invalid_attrs %{
    name: nil,
    email: nil
  }

  describe "list_users/1" do
    test "returns all users ordered by name" do
      user1 = user_fixture(%{name: "Bob"})
      user2 = user_fixture(%{name: "Alice"})
      users = Accounts.list_users()

      assert Enum.map(users, & &1.name) == ["Alice", "Bob"]
      assert Enum.map(users, & &1.id) == [user2.id, user1.id]
    end

    test "supports limit and offset" do
      for i <- 1..5 do
        user_fixture(%{name: "User#{i}"})
      end

      users = Accounts.list_users(limit: 2, offset: 1)
      assert length(users) == 2
    end

    test "supports name filtering with q" do
      _ = user_fixture(%{name: "Alice"})
      _ = user_fixture(%{name: "Bob"})

      users = Accounts.list_users(q: "ali")
      assert Enum.any?(users, &(&1.name == "Alice"))
      refute Enum.any?(users, &(&1.name == "Bob"))
    end

    test "ignores empty q param" do
      user = user_fixture(%{name: "Alice"})
      users = Accounts.list_users(q: "")
      assert Enum.any?(users, &(&1.id == user.id))
    end
  end

  describe "get_user/1" do
    test "returns a user by id" do
      user = user_fixture()
      assert Accounts.get_user(user.id).id == user.id
    end

    test "returns nil for unknown id" do
      assert Accounts.get_user(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_user_by_email/1" do
    test "returns a user by email" do
      user = user_fixture(%{email: "findme@example.com"})
      assert %User{} = Accounts.get_user_by_email("findme@example.com")
      assert user.id == Accounts.get_user_by_email("findme@example.com").id
    end

    test "returns nil for unknown email" do
      assert Accounts.get_user_by_email("missing@example.com") == nil
    end
  end

  describe "create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "Alice"
      assert user.email == "alice@example.com"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end
  end

  describe "get_or_create_user/1" do
    test "returns existing user if email exists" do
      user = user_fixture(%{email: "exists@example.com"})
      assert {:ok, found} = Accounts.get_or_create_user(%{email: "exists@example.com"})
      assert found.id == user.id
    end

    test "creates user if email does not exist" do
      assert {:ok, %User{} = user} =
               Accounts.get_or_create_user(%{name: "New", email: "new@example.com"})

      assert user.email == "new@example.com"
    end
  end

  describe "update_user/2" do
    test "with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = updated} = Accounts.update_user(user, @update_attrs)
      assert updated.name == "Alice Updated"
      assert updated.email == "alice.updated@example.com"
    end

    test "with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user.id == Accounts.get_user(user.id).id
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert Accounts.get_user(user.id) == nil
    end
  end

  describe "change_user/1" do
    test "returns a changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "prune_test_data/1" do
    test "removes users with seed marker in name" do
      user1 = user_fixture(%{name: "Alice [CI:seed123]"})
      _user2 = user_fixture(%{name: "Bob"})

      assert {:ok, count} = Accounts.prune_test_data("seed123")
      assert count == 1
      assert Accounts.get_user(user1.id) == nil
    end

    test "returns error when seed is missing or empty" do
      assert {:error, :seed_required} = Accounts.prune_test_data(nil)
      assert {:error, :seed_required} = Accounts.prune_test_data("")
    end
  end
end
