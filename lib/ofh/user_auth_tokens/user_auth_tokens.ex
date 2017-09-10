defmodule Ofh.UserAuthTokens do
  @moduledoc """
  The UserAuthTokens context.
  """
  # 15 minutes in miliseconds
  @refresh_token_ttl 60_000 * 15 # TODO: remove
  use Guardian, otp_app: :ofh

  alias Ofh.UserAuthTokens.UserRefreshToken

  alias Ofh.Repo
  # Depend on user context
  alias Ofh.Users
  alias Ofh.Users.User

  @doc """
  Gets a single refresh_token.

  Returns nil if no result was found
  """
  def get_refresh_token(id) do
    case Repo.get(UserRefreshToken, id) do
      %UserRefreshToken{} = token ->
        if token.expiry_date < now() do
          # Delete?
          nil
        else
          token
        end
      nil -> nil
    end
  end

  # user_from_refresh_token? But guess this this is some kind of behaviour that will also
  # be implementet for cart etc? Can't remember my own motivations behind this :)
  def resource_from_refresh_token(%UserRefreshToken{} = refresh_token) do
    # TODO: Fix this
    {:ok, Users.get_user!(refresh_token.user_id)}
  end

  # How to get rid of code duplication between this and
  # create_user_tokens? Perhaps ok?
  def exchange_refresh_token(token) do
    with {:ok, old_refresh_token} <- check_refresh_token(token),
         {:ok, new_refresh_token_struct} <- Repo.transaction(fn ->
           Repo.delete!(old_refresh_token)
           # Code smell, this is duplication of code in create_refresh_token
           # but we need insert!() here and insert() in create_refresh_token, hmm
           %UserRefreshToken{}
           |> UserRefreshToken.changeset(%{
             expiry_date: now() + @refresh_token_ttl, #TODO: get rid of this here and in schema etc
             user_id: old_refresh_token.user_id
           })
           |> Repo.insert!()
         end
         ),
         {:ok, new_refresh_token} <- refresh_token_parts(new_refresh_token_struct),
         {:ok, user} <- resource_from_refresh_token(new_refresh_token_struct),
         {:ok, access_token, _claims} <- create_access_token(user)
    do
      {:ok, access_token, new_refresh_token}
    else
      err -> err
    end
  end

  def check_refresh_token(token) do
    with %UserRefreshToken{} = refresh_token <- get_refresh_token(token) do
      {:ok, refresh_token}
    else
      nil -> {:error, :invalid_refresh_token}
    end
  end

  def create_tokens(%User{} = user) do
    with {:ok, access_token, _claims} <- create_access_token(user),
         {:ok, refresh_token_struct} <- create_refresh_token(user),
         {:ok, refresh_token} <- refresh_token_parts(refresh_token_struct)
    do
      {:ok, access_token, refresh_token}
    else
      err -> err
    end
  end

  # Context for refresh_token/opaque_token

  @doc """
  Creates a refresh_token.

  ## Examples

      iex> create_refresh_token(%{field: value})
      {:ok, %UserRefreshToken{}}

      iex> create_refresh_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_refresh_token(%User{} = user) do
    # TODO: expiry date missing
    attrs = %{
      user_id: user.id,
      expiry_date: now() + @refresh_token_ttl
    }
    %UserRefreshToken{}
    |> UserRefreshToken.changeset(attrs)
    |> Repo.insert()
  end

  defp refresh_token_parts(%UserRefreshToken{id: refresh_token}) do
    {:ok, refresh_token}
  end

  @doc """
  Deletes a RefreshToken.
  """
  def delete_refresh_token(%UserRefreshToken{} = refresh_token) do
    Repo.delete(refresh_token)
  end

  def create_access_token(%User{} = user) do
    # TODO: Fetch all accounts and save as grant ids
    # TODO: Load all accounts and save grant ids as map %{realm (account_type): grant_id, ..}
    # in claims.grants
    encode_and_sign(user, %{"aud" => "user"}, ttl: {15, :minutes})
  end

  # TEST:
  def subject_for_token(%User{:id => nil}, _claims) do
    {:ok, "User/"}
  end
  def subject_for_token(%User{} = user, _claims) do
		{:ok, "User/" <> user.id}
  end

  #def subject_for_token(%UserRefreshToken{} = refresh_token, _claims) do
  #	{:ok, "RefreshToken/" <> refresh_token.id}
  #end

  #def subject_for_token(%Cart{} = cart, _claims) do
  #  {:ok, "Cart/" <> cart.id}
  #end

  #def subject_for_token(_, _) do
  #	{:error, :reason_for_error}
  #end
  def resource_from_claims(claims) do
    # case claims["aud"] do
    case String.split(claims["sub"], "/") do
      ["User" | id] ->
        {:ok, Users.get_user!(id)} #TODO: function that returns touple
      _ ->
        {:error, :invalid_jwt_subject}
    end
  end

  defp now, do: System.system_time(:seconds) #TODO: remove this later
end
