defmodule OfhWeb.UserController do
  use OfhWeb, :controller

  alias Ofh.Users
  alias Ofh.Users.User

  action_fallback OfhWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json-api", data: users)
  end

  #def index(conn, %{"op" => "edit"}) do
    # What happens here?
    # %{realm => id, ...} map has ben stored in conn?
    # No, just ids, realms has been specified in plug thingy
    # so just list of ids
    # which we will is in IN-condition for user table grant_id field??
    # Could work
    # Think: Do we need relation table with grant_id + op? Perhaps? perhaps to complex
    #
    # If grant table:
    #
    # JOIN grants ON user_id = grants.resource_id AND grant_id IN ("123", "31243") AND op = "edit";
    #
    # else
    #
    # add: WHERE grant_id IN ("123", "12312312")
  #end

  def create(conn, %{"data" => %{"type" => "users", "attributes" => attrs}}) do
    with {:ok, %User{} = user} <- Users.create_user(attrs) do
      conn
      |> put_status(201)
      |> render("show.json-api", data: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.json-api", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)
    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json-api", data: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
