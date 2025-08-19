defmodule SDWeb.CredentialLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.AccountFixtures

  defp create_credential(_) do
    credential = credential_fixture()
    %{credential: credential}
  end

  describe "Index" do
    setup [:create_credential, :log_in_admin]

    test "lists all credentials", %{conn: conn, credential: credential} do
      {:ok, _index_live, html} = live(conn, ~p"/credentials")
      assert html =~ "Listing Credentials"
      assert html =~ credential.app_id
    end

    test "saves new credential", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/credentials")

      # open the New form (keep your existing link + redirect if your UI still pushes)
      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Credential")
               |> render_click()
               |> follow_redirect(conn, ~p"/credentials/new")

      assert render(form_live) =~ "New Credential"

      # Only submit fields present in the form. `datetime-local` needs "YYYY-MM-DDTHH:MM"
      create_attrs = %{"expires_at" => "2025-08-18T09:20"}

      # No redirect anymore — just render_submit and assert flash/content
      html =
        form_live
        |> form("#credential-form", credential: create_attrs)
        |> render_submit()

      assert html =~ "Credential created successfully"

      # (Optional) If your template renders the generated credentials, assert them too:
      # assert html =~ "app_"           # app_id prefix
      # assert html =~ "Private key"    # or any label/selector you show
    end

    test "deletes credential in listing", %{conn: conn, credential: credential} do
      {:ok, index_live, _html} = live(conn, ~p"/credentials")

      # the generator uses id="credentials-<id>"
      assert index_live
             |> element("#credentials-#{credential.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#credentials-#{credential.id}")
    end
  end

  describe "Show" do
    setup [:create_credential, :log_in_admin]

    test "displays credential", %{conn: conn, credential: credential} do
      {:ok, _show_live, html} = live(conn, ~p"/credentials/#{credential}")
      assert html =~ "Show Credential"
      assert html =~ credential.app_id
    end
  end
end
