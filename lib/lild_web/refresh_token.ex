defmodule LILDWeb.RefreshToken do
  use Joken.Config, default_signer: :hs256

  def encode(%{id: user_id}) do
    generate_and_sign(%{"sub" => user_id})
  end

  def decode(token) do
    verify_and_validate(token)
  end

  @impl true
  def token_config do
    default_claims(iss: "LILD", aud: "user", default_exp: 365 * 24 * 60 * 60)
    |> add_claim("token_type", fn -> "refresh" end, &(&1 == "refresh"))
  end
end
