defmodule LILDWeb.Router do
  use LILDWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", LILDWeb do
    pipe_through :api
  end
end
