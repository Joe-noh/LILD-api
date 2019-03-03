defmodule LILDWeb.SchemasTest do
  use ExUnit.Case, async: true

  setup_all do
    %{spec:  LILDWeb.ApiSpec.spec()}
  end

  LILDWeb.ApiSpec.spec().components.schemas
  |> Map.keys()
  |> Enum.map(fn schema_name ->
    test "example of #{schema_name} is correct", %{spec: spec} do
      schema = Module.concat([LILDWeb.Schemas, unquote(schema_name)]).schema()

      OpenApiSpex.Test.Assertions.assert_schema(schema.example, unquote(schema_name), spec)
    end
  end)
end
