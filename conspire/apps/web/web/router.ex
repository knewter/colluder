defmodule Conspire.Web.Router do
  use Conspire.Web.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Conspire.Web do
    pipe_through :api
  end
end
