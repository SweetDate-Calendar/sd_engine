defmodule SDWeb.TierLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.TiersFixtures
  import SD.CalendarsFixtures

  # @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}
  defp create_tier(_) do
    tier =
      tier_fixture()
      |> SD.Repo.preload(:account)

    _calendar1 = calendar_fixture(%{tier_id: tier.id, name: "Calendar 1"})
    _calendar2 = calendar_fixture(%{tier_id: tier.id, name: "Calendar 2"})

    %{tier: tier, account: tier.account}
  end

  describe "Show" do
    setup [:create_tier, :log_in_admin]

    test "displays tier", %{conn: conn, tier: tier, account: account} do
      {:ok, _show_live, html} = live(conn, ~p"/accounts/#{account}/tiers/#{tier}")

      assert html =~ "Show Tier"
      assert html =~ tier.name
    end

    test "updates tier", %{conn: conn, tier: tier, account: account} do
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{account}/tiers/#{tier}")

      assert {:ok, form_live, _} =
               show_live
               |> element("#edit-tier-#{tier.id}", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/accounts/#{account}/tiers/#{tier}/edit?return_to=show_tier"
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
                 ~p"/accounts/#{account}/tiers/#{tier}"
               )

      html = render(show_live)
      assert html =~ "Tier updated successfully"
      assert html =~ "some updated name"
    end
  end

  describe "Tier calendars" do
    setup [:create_tier, :log_in_admin]

    test "lists all calendars", %{conn: conn, tier: tier} do
      {:ok, _index_live, html} = live(conn, ~p"/accounts/#{tier.account_id}/tiers/#{tier.id}")

      tier = tier |> SD.Repo.preload(:calendars)

      assert html =~ "Calendars"

      for calendar <- tier.calendars do
        assert html =~ calendar.name
      end
    end

    test "saves new calendar", %{conn: conn, tier: tier} do
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{tier.account_id}/tiers/#{tier.id}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "New Calendar")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/tiers/#{tier}/calendars/new?return_to=show_tier"
               )

      assert render(form_live) =~ "New Calendar"

      assert form_live
             |> form("#calendar-form", calendar: %{tier_id: nil, name: nil})
             |> render_change() =~ "can&#39;t be blank"

      calendar_attrs = %{
        tier_id: tier.id,
        name: "some tier calendar",
        visibility: :shared,
        color_theme: "pink"
      }

      assert {:ok, show_live, _html} =
               form_live
               |> form("#calendar-form", calendar: calendar_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{tier.account_id}/tiers/#{tier.id}")

      html = render(show_live)
      assert html =~ "Calendar created successfully"
      assert html =~ "some tier calendar"
    end

    test "updates calendar in listing", %{conn: conn, tier: tier} do
      calendar = calendar_fixture(%{tier_id: tier.id, name: "some tier calendar name"})
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{tier.account_id}/tiers/#{tier.id}")

      assert {:ok, form_live, _html} =
               show_live
               |> element("#edit-calendar-#{calendar.id}", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/tiers/#{tier.id}/calendars/#{calendar}/edit?return_to=show_tier"
               )

      assert render(form_live) =~ "Edit Calendar"

      invalid_attrs = %{name: nil, color_theme: nil, visibility: nil}

      assert form_live
             |> form("#calendar-form", calendar: invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      update_attrs = %{
        name: "some updated tier calendar name",
        color_theme: "dusty",
        visibility: :public
      }

      assert {:ok, show_live, _html} =
               form_live
               |> form("#calendar-form", calendar: update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/accounts/#{tier.account_id}/tiers/#{tier.id}")

      html = render(show_live)
      assert html =~ "Calendar updated successfully"
      assert html =~ "some updated tier calendar name"
    end

    test "deletes calendar in listing", %{conn: conn, tier: tier} do
      calendar = calendar_fixture(%{tier_id: tier.id, name: "some tier calendar name"})
      {:ok, show_live, _html} = live(conn, ~p"/accounts/#{tier.account_id}/tiers/#{tier.id}")

      assert show_live |> element("#calendars-#{calendar.id} a", "Delete") |> render_click()
      refute has_element?(show_live, "#calendars-#{calendar.id}")
    end
  end
end
