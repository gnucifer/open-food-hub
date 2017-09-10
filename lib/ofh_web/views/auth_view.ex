defmodule OfhWeb.AuthView do
  use OfhWeb, :view
  #alias OfhWeb.AuthView

  def render("tokens.json", %{data: %{access_token: _, refresh_token: _} = tokens}) do
    tokens
  end
end
