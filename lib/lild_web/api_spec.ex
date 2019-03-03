defmodule LILDWeb.ApiSpec do
  alias OpenApiSpex.{OpenApi, Server, Info, Paths}

  def spec do
    OpenApiSpex.resolve_schema_modules(%OpenApi{
      servers: [
        %Server{url: "https://api.lild.app/"}
      ],
      info: %Info{
        title: "LILD API",
        version: "1.0"
      },
      paths: Paths.from_router(LILDWeb.Router)
    })
  end
end
