# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ofh, [
  ecto_repos: [Ofh.Repo],
  generators: [binary_id: true]
]

# Configures the endpoint
config :ofh, OfhWeb.Endpoint, [
  url: [host: "localhost"],
  secret_key_base: "YOh4lRVp2/Ofyo7pKmuSQ4b/Z1l0+zcc/a5LKQCszUEpFkn44iv638dBiD3uw6tT",
  render_errors: [view: OfhWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Ofh.PubSub, adapter: Phoenix.PubSub.PG2]
]

# Configures Elixir's Logger
config :logger, :console, [
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
]

config :ofh, Ofh.UserAuthTokens, [
  issuer: "ofh",
  secret_key: "T2y4/ZS0f/19uQm4otUVzVewfSZIa9DyMr8Bcg02q+S5yZgAI8of3RPeb9XnEYlZ"
]

config :ofh, OfhWeb.AuthAccessPipeline, [
  module: Ofh.UserAuthTokens,
  error_handler: OfhWeb.AuthErrorHandler
]

config :ueberauth, Ueberauth, [
  base_path: "/auth",
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]
]

config :phoenix, :format_encoders, [
  "json-api": Poison
]

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
