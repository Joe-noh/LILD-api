defmodule LILDWeb.RefreshTokenTest do
  use ExUnit.Case, async: true

  alias LILDWeb.{AccessToken, RefreshToken}

  test "payload" do
    {:ok, jwt, payload} = RefreshToken.encode(%{id: "12345"})
    {:ok, ^payload} = RefreshToken.decode(jwt)

    assert payload["sub"] == "12345"
    assert payload["aud"] == "user"
    assert payload["iss"] == "LILD"
    assert payload["token_type"] == "refresh"
    assert_in_delta payload["exp"] - payload["iat"], 365 * 24 * 60 * 60, 1
  end

  test "access tokenを代わりに使えない" do
    {:ok, refresh_token, _payload} = AccessToken.encode(%{id: "12345"})
    assert {:error, _} = RefreshToken.decode(refresh_token)
  end
end
