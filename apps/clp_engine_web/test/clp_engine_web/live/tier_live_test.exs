defmodule CLPWeb.TierLiveTest do
  use CLPWeb.ConnCase

  import Phoenix.LiveViewTest
  import CLP.TiersFixtures

  # @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_tier(_) do
    tier =
      tier_fixture()
      |> CLP.Repo.preload(:account)

    %{tier: tier, account: tier.account}
  end

  describe "Index" do
    setup [:create_tier]

    test "lists all tiers", %{conn: conn, tier: tier, account: account} do
      {:ok, _index_live, html} = live(conn, ~p"/accounts/#{account}")

      assert html =~ "Tiers"
      assert html =~ tier.name
    end

    test "saves new tier", %{conn: conn, account: account} do
      create_attrs = Map.put(%{name: "some new tier name"}, :account_id, account.id)

      {:ok, index_live, _html} = live(conn, ~p"/accounts/#{account.id}")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Tier")
               |> render_click()
               |> follow_redirect(conn, ~p"/accounts/#{account.id}/tiers/new")

      assert render(form_live) =~ "New Tier"

      assert form_live
             |> form("#tier-form", tier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tier-form", tier: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{account.id}")

      html = render(index_live)
      assert html =~ "Tier created successfully"
      assert html =~ "some new tier name"
    end

    test "updates tier in listing", %{conn: conn, tier: tier, account: account} do
      {:ok, index_live, _html} = live(conn, ~p"/accounts/#{account}")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#tiers-#{tier.id} a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}/tiers/#{tier}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Tier"

      assert form_live
             |> form("#tier-form", tier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#tier-form", tier: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{account}")

      html = render(index_live)
      assert html =~ "Tier updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes tier in listing", %{conn: conn, tier: tier, account: account} do
      {:ok, index_live, _html} = live(conn, ~p"/accounts/#{account}")

      assert index_live |> element("#tiers-#{tier.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tiers-#{tier.id}")
    end
  end

  describe "Show" do
    setup [:create_tier]

    test "displays tier", %{conn: conn, tier: tier, account: account} do
      {:ok, _show_live, html} = live(conn, ~p"/accounts/#{account}/tiers/#{tier}")

      assert html =~ "Show Tier"
      assert html =~ tier.name
    end

    test "updates tier and returns to account show", %{conn: conn, tier: tier, account: account} do
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{account}/tiers/#{tier}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}/tiers/#{tier}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Tier"

      assert form_live
             |> form("#tier-form", tier: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#tier-form", tier: @update_attrs)
               |> render_submit()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}"
               )

      html = render(show_live)
      assert html =~ "Tier updated successfully"
      assert html =~ "some updated name"
    end
  end
end
