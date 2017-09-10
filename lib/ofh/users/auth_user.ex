defmodule Ofh.Users.AuthUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ofh.Users.AuthUser


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "auth_users" do
    field :auth_uid, :string
    field :extra, :string
    field :info, :string
    field :provider, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(%AuthUser{} = auth_user, attrs) do
    auth_user
    |> cast(attrs, [:auth_uid, :provider, :info, :extra])
    |> validate_required([:auth_uid, :provider, :info, :extra])
    |> unique_constraint(:unique_auth_user, name: :auth_users_auth_id_provider_user_id_index)
  end
end
