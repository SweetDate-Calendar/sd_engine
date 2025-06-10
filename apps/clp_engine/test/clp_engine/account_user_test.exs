defmodule CLP.Accounts.AccountUserTest do
  use CLP.DataCase, async: true

  alias CLP.Accounts
  alias CLP.Accounts.AccountUser
  alias CLP.Repo

  import CLP.AccountsFixtures

  describe "accounts_users join" do
    test "user can be added to account and accessed from both sides" do
      user = user_fixture()
      account = account_fixture()

      Accounts.create_account_user(account.id, user.id)

      user = Repo.preload(user, :accounts)
      assert Enum.any?(user.accounts, &(&1.id == account.id))

      account = Repo.preload(account, :users)
      assert Enum.any?(account.users, &(&1.id == user.id))
    end

    test "deleting user removes account_user row" do
      user = user_fixture()
      account = account_fixture()

      Accounts.create_account_user(account.id, user.id)

      Repo.delete!(user)

      refute Repo.exists?(
               from(au in AccountUser,
                 where: au.account_id == ^account.id and au.user_id == ^user.id
               )
             )
    end

    test "deleting account removes account_user row" do
      user = user_fixture()
      account = account_fixture()

      Accounts.create_account_user(account.id, user.id)

      Repo.delete!(account)

      refute Repo.exists?(
               from(au in AccountUser,
                 where: au.account_id == ^account.id and au.user_id == ^user.id
               )
             )
    end
  end
end
