defmodule LILDWeb.AccessTokenTest do
  use ExUnit.Case, async: true

  alias LILDWeb.AccessToken

  test "payload" do
    {:ok, jwt, payload} = AccessToken.encode(%{id: "12345"})
    {:ok, ^payload} = AccessToken.decode(jwt)

    assert payload["sub"] == "12345"
    assert payload["aud"] == "user"
    assert payload["iss"] == "LILD"
    assert_in_delta payload["exp"] - payload["iat"], 24 * 60 * 60, 1
  end
end
