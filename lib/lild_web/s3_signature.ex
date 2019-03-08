defmodule LILDWeb.S3Signature do
  def sign(user, prefix, mimetype) do
    [bucket: bucket, access_key_id: access_key_id, secret_access_key: secret_access_key] =
      Application.get_env(:lild, :s3)
      |> Keyword.take([:bucket, :access_key_id, :secret_access_key])

    key = Path.join([prefix, user.id, Ecto.ULID.generate() <> mime_to_ext(mimetype)])
    policy = policy(bucket, key, mimetype)

    %{
      key: key,
      'Content-Type': mimetype,
      acl: "private",
      success_action_status: "201",
      action: "https://#{bucket}.s3.amazonaws.com/",
      AWSAccessKeyId: access_key_id,
      policy: policy,
      signature: hmac_sha1(secret_access_key, policy)
    }
  end

  def valid_mimetype?("image/jpeg"), do: true
  def valid_mimetype?("image/png"), do: true
  def valid_mimetype?(_), do: false

  defp mime_to_ext("image/jpeg"), do: ".jpg"
  defp mime_to_ext("image/png"), do: ".png"
  defp mime_to_ext(mimetype), do: raise "Unsuppoerted mimetype: #{mimetype}"

  defp policy(bucket, key, mimetype, expiration_seconds \\ 60) do
    %{
      expiration: now_plus(expiration_seconds),
      conditions: [
        %{bucket: bucket},
        %{key: key},
        %{'Content-Type': mimetype},
        %{acl: "private"},
        %{success_action_status: "201"},
        ["content-length-range", 0, 3 * 1024 * 1024] # 3MB
      ]
    }
    |> Jason.encode!
    |> Base.encode64
  end

  defp now_plus(seconds) do
    DateTime.utc_now()
    |> DateTime.add(seconds, :second)
    |> DateTime.to_iso8601()
  end

  defp hmac_sha1(secret, message) do
    :crypto.hmac(:sha, secret, message) |> Base.encode64
  end
end
