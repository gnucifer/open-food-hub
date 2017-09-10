defmodule Ofh.UserAuthTokens.UserRefreshToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ofh.UserAuthTokens.UserRefreshToken


  @required [:expiry_date, :user_id] #:user_id?????

  #TODO: FIX, token should be primary key
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_refresh_tokens" do
    field :expiry_date, :integer
    belongs_to :user, Ofh.Users.User
    timestamps()
  end

  @doc false
  def changeset(%UserRefreshToken{} = refresh_token, attrs) do
    refresh_token
    |> cast(attrs, @required)
    |> validate_required(@required)
  end
end
