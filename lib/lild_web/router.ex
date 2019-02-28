defmodule LILDWeb.Router do
  use LILDWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug LILDWeb.CurrentUserPlug
  end

  scope "/v1", LILDWeb do
    pipe_through :api

    resources "/users", UserController, only: [:show, :create, :update, :delete], alias: User do
      resources "/dreams", DreamController, only: [:index, :show, :create, :update, :delete]
    end
    resources "/tags", TagController, only: [:index]
  end
end
