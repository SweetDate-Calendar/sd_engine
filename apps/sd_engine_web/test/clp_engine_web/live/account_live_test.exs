defmodule SDWeb.AccountLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.AccountsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_account(_) do
    account = account_fixture()
    _tenant = SD.TenantsFixtures.tenant_fixture(%{account_id: account.id})
    _tenant = SD.TenantsFixtures.tenant_fixture(%{account_id: account.id})

    %{account: account}
  end

  describe "Index" do
    setup [:create_account, :log_in_admin]

    test "lists all accounts", %{conn: conn, account: account} do
      {:ok, _index_live, html} = live(conn, ~p"/accounts")

      assert html =~ "Listing Accounts"
      assert html =~ account.name
    end

    test "saves new account", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/accounts")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Account")
               |> render_click()
               |> follow_redirect(conn, ~p"/accounts/new")

      assert render(form_live) =~ "New Account"

      assert form_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#account-form", account: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts")

      html = render(index_live)
      assert html =~ "Account created successfully"
      assert html =~ "some name"
    end

    test "updates account in listing", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, ~p"/accounts")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#accounts-#{account.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/accounts/#{account}/edit")

      assert render(form_live) =~ "Edit Account"

      assert form_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#account-form", account: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts")

      html = render(index_live)
      assert html =~ "Account updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes account in listing", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, ~p"/accounts")

      assert index_live |> element("#accounts-#{account.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#accounts-#{account.id}")
    end
  end

  describe "Show" do
    setup [:create_account, :log_in_admin]

    test "displays account", %{conn: conn, account: account} do
      {:ok, _show_live, html} = live(conn, ~p"/accounts/#{account}")

      assert html =~ "Show Account"
      assert html =~ account.name
    end

    test "updates account and returns to show", %{conn: conn, account: account} do
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{account}")

      assert {:ok, form_live, _} =
               show_live
               |> element("#edit-account-btn")
               |> render_click()
               |> follow_redirect(conn, ~p"/accounts/#{account}/edit?return_to=show")

      assert render(form_live) =~ "Edit Account"

      assert form_live
             |> form("#account-form", account: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#account-form", account: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{account}")

      html = render(show_live)
      assert html =~ "Account updated successfully"
      assert html =~ "some updated name"
    end
  end

  describe "Account tenants" do
    setup [:create_account, :log_in_admin]

    test "lists all tenants", %{conn: conn, account: account} do
      account =
        account
        |> SD.Repo.preload(:tenants)

      {:ok, _index_live, html} = live(conn, ~p"/accounts/#{account}")

      assert html =~ "Tenants"

      for tenant <- account.tenants do
        assert html =~ tenant.name
      end
    end

    test "saves new tenant", %{conn: conn, account: account} do
      {:ok, index_live, _html} = live(conn, ~p"/accounts/#{account.id}")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Tenant")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account.id}/tenants/new?return_to=show_account"
               )

      assert render(form_live) =~ "New Tenant"

      assert form_live
             |> form("#tenant-form", tenant: %{account_id: nil, name: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tenant-form",
                 tenant: %{account_id: account.id, name: "some new tenant name"}
               )
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{account.id}")

      html = render(index_live)
      assert html =~ "Tenant created successfully"
      assert html =~ "some new tenant name"
    end

    test "deletes tenant in listing", %{conn: conn, account: account} do
      tenant =
        SD.TenantsFixtures.tenant_fixture(%{account_id: account.id, name: "Tenant to delete"})

      {:ok, index_live, _html} = live(conn, ~p"/accounts/#{account}")

      assert index_live |> element("#tenants-#{tenant.id} a", "Delete") |> render_click()

      refute has_element?(index_live, "#tenants-#{tenant.id}")
    end

    test "updates tenant", %{conn: conn, account: account} do
      tenant = SD.TenantsFixtures.tenant_fixture(%{account_id: account.id, name: "Edit me"})
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{account}")

      assert {:ok, form_live, _} =
               show_live
               |> element("#edit-tenant-#{tenant.id}")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account.id}/tenants/#{tenant}/edit?return_to=show_account"
               )

      assert render(form_live) =~ "Edit Tenant"

      assert form_live
             |> form("#tenant-form", tenant: %{account_id: nil, name: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#tenant-form",
                 tenant: %{account_id: account.id, name: "some updated tenant name"}
               )
               |> render_submit()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}"
               )

      html = render(show_live)
      assert html =~ "Tenant updated successfully"
      assert html =~ "some updated tenant name"
    end
  end
end
