defmodule Ofh.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ofh.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required [:username, :email]
  @optional [:name]

  schema "users" do
    field :username, :string
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  #TODO: correct place to set defaults? If name not set set to email, if username not set set to name
  # TODO: What we really should do is set random password, else we are fucked, fix!
  @doc false
  def changeset_without_password(%User{} = user, attrs) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> changeset_without_password(attrs)
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 6) # TODO: use not_qwerty123
    #|> validate_required([:password]) # This not needed when validate length?
    |> put_password_hash
  end

	#TODO: or just %{?
	defp put_password_hash(
		%Ecto.Changeset{
			valid?: true,
			changes: %{password: password}
		} = changeset
	) do
		change(
			changeset,
			Comeonin.Argon2.add_hash(password, hash_key: :password_hash)
		)
	end
	defp put_password_hash(changeset), do: changeset
end
