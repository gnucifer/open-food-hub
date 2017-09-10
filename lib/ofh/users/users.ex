defmodule Ofh.Users do
  @moduledoc """
  The Users context.
  """
  import Ecto.Query, warn: false
  #import Ecto.Query, only: [from: 2]

  alias Ofh.Repo

  alias Ofh.Users.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id), do: Repo.get!(User, id)

  #@doc """
  #Gets a single user by email.
	#
  #Raises `Ecto.NoResultsError` if the User does not exist.
  #"""
  #def by_email(query, email) do
  #  from u in query, where: u.email = ^email
  #end

  #@doc """
  #Gets a single user by username.
	#
  #Raises `Ecto.NoResultsError` if the User does not exist.
  #"""
  #def by_username(query, username), do
  #  from u in query, where: u.username = ^username
  #end

  @doc """
  Gets a single user by email or username.

  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user_by_email_or_username!(email_or_username) do
    (from u in User,
    	where: u.email == ^email_or_username or u.username == ^email_or_username)
		|> Repo.one()
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user with a password.
  """
  def create_user_without_password(attrs \\ %{}) do
    %User{}
    |> User.changeset_without_password(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
