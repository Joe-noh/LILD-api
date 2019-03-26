defmodule LILDWeb.AccessTokenTest do
  use ExUnit.Case, async: true

  alias LILDWeb.{AccessToken, RefreshToken}

  test "payload" do
    {:ok, jwt, payload} = AccessToken.encode(%{id: "12345"})
    {:ok, ^payload} = AccessToken.decode(jwt)

    assert payload["sub"] == "12345"
    assert payload["aud"] == "user"
    assert payload["iss"] == "LILD"
    assert payload["token_type"] == "access"
    assert_in_delta payload["exp"] - payload["iat"], 24 * 60 * 60, 1
  end

  test "refresh tokenを代わりに使えない" do
    {:ok, refresh_token, _payload} = RefreshToken.encode(%{id: "12345"})
    assert {:error, _} = AccessToken.decode(refresh_token)
  end
end
