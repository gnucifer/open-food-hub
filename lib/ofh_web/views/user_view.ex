defmodule OfhWeb.UserView do
  use OfhWeb, :view
  use JaSerializer.PhoenixView

  alias OfhWeb.UserView

  attributes [:username, :name, :email]
end
