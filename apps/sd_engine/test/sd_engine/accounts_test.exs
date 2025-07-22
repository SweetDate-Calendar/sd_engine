defmodule SD.AccountsTest do
  use SD.DataCase

  alias SD.Accounts
  alias SD.Accounts.Account

  import SD.AccountsFixtures

  describe "accounts" do
    @invalid_attrs %{name: nil}

    setup do
      account = authorized_account_fixture()

      %{account: account}
    end

    test "list_accounts/0 returns all accounts", %{account: account} do
      account_b = account_fixture()

      result = Accounts.list_accounts()
      ids = Enum.map(result, & &1.id)

      expected_ids = [account.id, account_b.id]
      assert Enum.sort(ids) == Enum.sort(expected_ids)
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Account{} = account} = Accounts.create_account(valid_attrs)
      assert account.name == "some name"
      assert account.api_secret
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.name == "some updated name"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      refute Accounts.get_account(account.id)
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "users" do
    alias SD.Accounts.User

    import SD.AccountsFixtures

    @invalid_attrs %{name: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "get_user_by_email/1 returns the user with given email" do
      user = user_fixture()
      assert Accounts.get_user_by_email(user.email) == user
    end

    test "get_user_by_email/1 returns nil if there is no user with the given email " do
      # user = user_fixture()
      refute Accounts.get_user_by_email("not-in-system@example.com")
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", email: "some-email@example.com"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email == "some-email@example.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "get_or_create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", email: "some-email@example.com"}

      assert {:ok, %User{} = user} = Accounts.get_or_create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email == "some-email@example.com"
    end

    test "get_or_create_user/1 finds a user if the user by email" do
      user = user_fixture()
      valid_attrs = %{email: user.email}

      assert {:ok, %User{} = found_user} = Accounts.get_or_create_user(valid_attrs)
      assert user.email == found_user.email
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", email: "some-updated-email@example.com"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.email == "some-updated-email@example.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      refute Accounts.get_user(user.id)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "tenants" do
    test "create_tenant/1 with valid data creates a tenant" do
      account = account_fixture()

      valid_attrs = %{name: "some name", account_id: account.id}

      assert {:ok, %SD.Tenants.Tenant{} = tenant} = Accounts.create_tenant(valid_attrs)
      assert tenant.name == "some name"
    end

    test "create_tenant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_tenant(%{name: nil, account_id: nil})
    end
  end
end
