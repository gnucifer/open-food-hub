defmodule OfhWeb.AuthAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :ofh
  plug Guardian.Plug.VerifyHeader, realm: "Bearer", claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated#, claims: %{}
end
