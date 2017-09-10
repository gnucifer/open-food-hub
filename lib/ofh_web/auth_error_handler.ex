defmodule OfhWeb.AuthErrorHandler do
  import Plug.Conn

  @http_status 401
  @title "Access denied"

  def auth_error(conn, {type, reason}, _opts) do
    # TODO: JSONAPI helper/plug/something
    body = Poison.encode!(%{errors: [%{id: to_string(type), status: @http_status, code: to_string(reason), title: @title}]})
    send_resp(conn, @http_status, body)
  end
end
