defmodule SDWeb.CredentialLiveTest do
  use SDWeb.ConnCase

  import Phoenix.LiveViewTest
  import SD.AccountFixtures

  # invalid remains useful for form validations
  @invalid_attrs %{
    status: nil,
    public_key: nil,
    app_id: nil,
    alg: nil,
    expires_at: nil,
    last_used_at: nil
  }

  # helper to build valid create attrs with a real Ed25519 pubkey (base64url)
  defp valid_create_attrs do
    {pub, _priv} = :crypto.generate_key(:eddsa, :ed25519)
    pub_b64 = Base.url_encode64(pub, padding: false)

    %{
      # Ecto.Enum
      status: :active,
      # base64url, 32 bytes
      public_key: pub_b64,
      app_id: "some_app_id",
      # Ecto.Enum
      alg: :ed25519,
      # strings are okay for utc_datetime(_usec) casts in generated LV forms
      expires_at: "2025-08-18T09:20:00Z",
      last_used_at: "2025-08-18T09:20:00Z"
    }
  end

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

      # Go to "new" form (generator typically push_patches; follow_redirect handles both)
      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Credential")
               |> render_click()
               |> follow_redirect(conn, ~p"/credentials/new")

      assert render(form_live) =~ "New Credential"

      # invalid shows errors
      assert form_live
             |> form("#credential-form", credential: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # valid create
      create_attrs = valid_create_attrs()

      assert {:ok, index_live, _html} =
               form_live
               |> form("#credential-form", credential: create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/credentials")

      html = render(index_live)
      assert html =~ "Credential created successfully"
      assert html =~ "some_app_id"
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
