defmodule SDTCP.Handlers.AuthTest do
  # use SDTCP.DataCase, async: false
  # import SDTCP.TestHelper

  # @valid_payload %{
  #   "provisioning_key" => System.get_env("CLP_PROVISIONING_KEY"),
  #   "secret_key_id" => "test-client-123",
  #   "secret_key" => "supersecretkey",
  #   "tenant" => "pro",
  #   "active" => "true",
  #   "account_id" => "6ccd5251-8b8e-4fd9-ac42-2452e66100c2",
  #   "metadata" => %{"role" => "test"}
  # }

  # test "AUTH.CREATE creates an authorization hold" do
  #   response = sd_send("AUTH.CREATE|#{Jason.encode!(@valid_payload)}")
  #   assert response["status"] == "ok"

  #   auth = CP.Auth.get_by_key("test-client-123", "supersecretkey")
  #   assert auth.tenant == :pro
  #   assert auth.active
  #   assert auth.metadata["role"] == "test"
  # end

  # test "AUTH.GET returns the created authorization hold" do
  #   sd_send("AUTH.CREATE|#{Jason.encode!(@valid_payload)}")

  #   response =
  #     sd_send(
  #       "AUTH.GET|#{Jason.encode!(%{"secret_key_id" => "test-client-123", "secret_key" => "supersecretkey"})}"
  #     )

  #   assert response["status"] == "ok"
  #   assert response["authorization_hold"]["secret_key_id"] == "test-client-123"
  # end

  # test "AUTH.LIST returns list of authorization holds" do
  #   sd_send("AUTH.CREATE|#{Jason.encode!(@valid_payload)}")

  #   response = sd_send("AUTH.LIST|{}")
  #   assert response["status"] == "ok"

  #   assert Enum.any?(response["authorization_holds"], fn hold ->
  #            hold["secret_key_id"] == "test-client-123"
  #          end)
  # end

  # test "AUTH.UPDATE updates metadata" do
  #   sd_send("AUTH.CREATE|#{Jason.encode!(@valid_payload)}")

  #   response =
  #     sd_send(
  #       "AUTH.UPDATE|#{Jason.encode!(%{"secret_key_id" => "test-client-123", "secret_key" => "supersecretkey", "metadata" => %{"role" => "admin"}})}"
  #     )

  #   assert response["status"] == "ok"
  #   assert response["authorization_hold"]["metadata"]["role"] == "admin"
  # end

  # test "AUTH.DELETE removes the authorization hold" do
  #   sd_send("AUTH.CREATE|#{Jason.encode!(@valid_payload)}")

  #   response =
  #     sd_send(
  #       "AUTH.DELETE|#{Jason.encode!(%{"secret_key_id" => "test-client-123", "secret_key" => "supersecretkey"})}"
  #     )

  #   assert response["status"] == "ok"

  #   assert sd_send(
  #            "AUTH.GET|#{Jason.encode!(%{"secret_key_id" => "test-client-123", "secret_key" => "supersecretkey"})}"
  #          )["status"] == "error"
  # end

  # test "AUTH.CREATE fails with invalid provisioning key" do
  #   payload = Map.put(@valid_payload, "provisioning_key", "wrong-key")

  #   response = sd_send("AUTH.CREATE|#{Jason.encode!(payload)}")

  #   assert response["status"] == "error"
  #   assert response["message"] == "unauthorized"
  # end
end
