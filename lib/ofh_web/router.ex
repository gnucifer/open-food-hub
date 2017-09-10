defmodule OfhWeb.Router do
  use OfhWeb, :router
  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery #TODO: What does this do?
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jsonapi do
    plug :accepts, ["json-api"] #application/vnd.api+json
    plug JaSerializer.ContentTypeNegotiation
  end

  pipeline :jsonapi_authorized do
    plug OfhWeb.AuthAccessPipeline
  end

  # TODO: Anonymous user id as setting?
  #pipeline :jsonapi_anonymous do
  #  plug OfhWeb.AuthAccessPipeline#, %{claims: %{subject: "Users/anonymous"}}
  #end

  scope "/", OfhWeb do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

  scope "/auth", OfhWeb do
    pipe_through :browser
		get "/:provider", AuthController, :request
		get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/auth", OfhWeb do
    pipe_through :api
    post "/authorize", AuthController, :authorize_user
    # This has nothing to do with OAuth, just sharing some naming conventions etc
    #delete "/refresh_tokens", UserController, singleton: true
  end

  scope "/api/v1", OfhWeb do
    pipe_through [:jsonapi] #TODO: captcha, or email verification enough? Probably
    resources "/users", UserController, only: [:create]
  end

  scope "/api/v1", OfhWeb do
    pipe_through [:jsonapi, :jsonapi_authorized] #maybe_authorized?
    resources "/users", UserController, only: [:show, :index, :update, :delete] #
    #get "/user/current", UserCohntroller, :current, as: :current_user #??
    #delete "/logout", AuthController, :delete
  end

  #scope "/api/v1/auth", Ofh do
  #	pipe_through :api
  #	get "/:provider", AuthController, :request
  #	get "/:provider/callback", AuthController, :callback
  #	post "/:provider/callback", AuthController, :callback
  #end
end
