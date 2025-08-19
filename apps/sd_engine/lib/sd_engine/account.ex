defmodule SD.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias SD.Repo

  alias SD.Account.Credential

  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential!(123)
      %Credential{}

      iex> get_credential!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credential!(id), do: Repo.get!(Credential, id)

  @doc """
  Gets an **active** credential by its `app_id`.

  Returns the `%Credential{}` if found and `status == :active` (or `"active"` if stored as string),
  otherwise returns `nil`.

  ## Examples

      iex> get_active_credential_by_app_id("app_123").id
      "…"

      iex> get_active_credential_by_app_id("missing")
      nil

      iex> get_active_credential_by_app_id("disabled_app")
      nil
  """
  def get_active_credential_by_app_id(app_id) when is_binary(app_id) do
    Repo.get_by(Credential, app_id: app_id, status: :active)
  end

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Generates a new credential:

  - app_id: auto (e.g. "app_" <> UUID)
  - alg: :ed25519
  - status: :active
  - public_key: from generated keypair
  - returns: `{:ok, credential, private_key_bin}` (private key is **not stored**)

  Accepts optional attrs like `:expires_at` (and `:label` if you add that field later).
  Any user-supplied `public_key`, `alg`, `status`, `app_id` are ignored for safety.
  """
  @spec generate_credential(map()) ::
          {:ok, SD.Account.Credential.t(), binary()}
          | {:error, Ecto.Changeset.t()}
  def generate_credential(attrs \\ %{}) do
    # 1) keys
    {pub, priv} = :crypto.generate_key(:eddsa, :ed25519)
    pub_b64 = Base.url_encode64(pub, padding: false)

    # 2) app_id
    app_id = "app_" <> Ecto.UUID.generate()

    # 3) build safe params (ignore unsafe inputs)
    safe =
      attrs
      # allow only these for now
      |> Map.take([:expires_at, :last_used_at])
      |> Map.merge(%{
        app_id: app_id,
        public_key: pub_b64,
        alg: :ed25519,
        status: :active
      })

    case create_credential(safe) do
      {:ok, cred} -> {:ok, cred, priv}
      {:error, cs} -> {:error, cs}
    end
  end

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential)
      %Ecto.Changeset{data: %Credential{}}

  """
  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset(credential, attrs)
  end
end
