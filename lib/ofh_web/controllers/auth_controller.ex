#TODO: Create AuthTokens context!!!?

defmodule OfhWeb.AuthController do
  use OfhWeb, :controller
  import Ecto.Changeset

  #alias Ueberauth.Strategy.Helpers
  alias Ofh.UserAuthTokens
  alias Ofh.UserAuthTokens.UserRefreshToken
  alias Ofh.Users
  #alias Ofh.Users.User

  # FIXME: This is either really elegant or ugly, can't decide which
  #@anonymous_username "anonymous"
  #@anonumous_user %User{username: @anomuous_username}

  # TODO: Idea, perhaps separate auth-user from user also for password athentication
  # to get rid of ugly user creation and intimate dependency here
  #
  # alternative solution: generate anynumous user token that is valid only for creating users, probably not a bad idea!

  # Users context

  # TODO: Tokens context
  # alias Ofh.Tokens

  plug Ueberauth
	action_fallback OfhWeb.FallbackController

  #def request(conn, _params) do
  #	render(conn, "request.json", callback_url: Helpers.callback_url(conn))
  #end

	def delete(conn, _params) do
    #conn
    #|> configure_session(drop: true)
    # TODO: Delete refersh-token from db
    conn
	end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    # TODO: Redirect to ember with error in url?
		conn
		#|> put_flash(:error, "Failed to authenticate.")
		# TODO: json error, fallback controller?
		|> redirect(to: "/")
	end

	def callback(%{assigns: %{ueberauth_auth: _auth}} = conn, _params) do
		#TODO: User is authenticated: generate JWT access token and refresh token (which is not a JWT)
		# Then generate json response with this information I guess, check how oath responds
		render(conn, "tokens.json", access_token: "todo", refresh_token: "todo")
    #UserFromAuth.find_or_create(auth)
  end

  # Genererate jwt for anonymous user
  # Probably crap idea
  #def authorize_user(conn, %{grant_type: "password", username_or_email: @anonymous_username, password: ""}) do
  #  # TODO: code duplication: if this is viable, perhaps put in defp
  #  with {:ok, access_token, refresh_token} <- UserAuthTokens.create_tokens(@anonumous_user) do
  #    render(conn, "tokens.json", %{data: tokens_data(access_token, refresh_token)})
  #  else
  #    err -> err
  #  end
  #end

  def authorize_user(conn, %{"grant_type" => "password"} = params) do
    data = %{}
    types = %{username_or_email: :string, password: :string}
    required = Map.keys(types)
    {data, types}
    |> cast(params, required)
    |> validate_required(required)
    |> update_change(:username_or_email, &String.downcase/1)
    |> check_password()
    |> case do
      %{valid?: false} = changeset ->
        # Let fallback controller deal with this
        # TODO: This is boilerplaty, also handle invalid changesets in fallback controller directly?
        {:error, changeset}
      %{changes: %{user_id: user_id}} ->
        user = Users.get_user!(user_id)
        with {:ok, access_token, refresh_token} <- UserAuthTokens.create_tokens(user) do
          render(conn, "tokens.json", %{data: tokens_data(access_token, refresh_token)})
        else
          err -> err
        end
    end
  end

  #### START HERE ####
  # Refresh token JWT or user in table?

  # Or generic authenticate, grant_type = password/refresh_token etc??
  def authorize_user(conn, %{"grant_type" => "refresh_token"} = params) do
    data = %{}
    types = %{refresh_token: :string}
    required = Map.keys(types)
    {data, types}
    |> cast(params, required)
    |> validate_required(required)
    |> case do
      %{valid?: false} = changeset ->
        {:error, changeset}
      %{changes: %{refresh_token: refresh_token}} ->
        # Make refresh token generic for all JWTs? Include resource in schema
        with {:ok, access_token, refresh_token} <- UserAuthTokens.exchange_refresh_token(refresh_token) do
          render(conn, "tokens.json", %{data: tokens_data(access_token, refresh_token)})
        else
          err -> err
        end
    end
  end

  defp tokens_data(access_token, refresh_token) do
    %{
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  # TODO: Sould this live in context module? Most likely yes
  defp check_password(%{valid?: false} = changeset), do: changeset
  defp check_password(%{changes: %{username_or_email: username_or_email, password: password}} = changeset) do
    # FIXME: Here we have a direct user-context dependency, is this ok?
    add_incorrect_pw_error = fn(changeset) -> add_error(changeset, :password, "is incorrect") end
		case Users.get_user_by_email_or_username!(username_or_email) do
      nil ->
        # Do dummy password check to prevent timing attacks
        Comeonin.Argon2.dummy_checkpw()
        add_incorrect_pw_error.(changeset)
      user ->
			  if Comeonin.Argon2.checkpw(password, user.password_hash) do
				  put_change(changeset, :user_id, user.id)
			  else
          add_incorrect_pw_error.(changeset)
			  end
	  end
  end
end
