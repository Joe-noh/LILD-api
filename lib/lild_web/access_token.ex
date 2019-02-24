defmodule LILDWeb.AccessToken do
  use Joken.Config, default_signer: :hs256

  def encode(%{id: user_id}) do
    generate_and_sign(%{"sub" => user_id})
  end

  def decode(token) do
    verify_and_validate(token)
  end

  @impl true
  def token_config do
    default_claims(iss: "LILD", aud: "User", default_exp: 24 * 60 * 60)
  end
end
