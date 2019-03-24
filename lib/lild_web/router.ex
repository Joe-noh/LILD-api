defmodule LILDWeb.Router do
  use LILDWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug LILDWeb.CurrentUserPlug
  end

  scope "/v1", LILDWeb do
    pipe_through :api

    resources "/sessions", SessionController, only: [:create]

    scope "/my", alias: My, as: :my do
      resources "/dreams", DreamController, only: [:index]

      scope "/dreams", alias: Dream, as: :dream do
        resources "/draft", DraftController, only: [:index]
      end
    end

    resources "/users", UserController, only: [:show, :create, :update, :delete], alias: User do
      resources "/dreams", DreamController, only: [:index, :show, :create, :update, :delete], alias: Dream do
        resources "/reports", ReportController, only: [:create]
      end
    end

    resources "/tags", TagController, only: [:index], alias: Tag do
      resources "/dreams", DreamController, only: [:index]
    end

    resources "/presigns", PresignController, only: [:create]
  end
end
