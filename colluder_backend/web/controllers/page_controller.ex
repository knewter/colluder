defmodule ColluderBackend.PageController do
  use ColluderBackend.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
