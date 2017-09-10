defmodule OfhWeb.PageController do
  use OfhWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
