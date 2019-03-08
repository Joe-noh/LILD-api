defmodule LILDWeb.S3Signature do
  def sign(filename, mimetype) do
    [bucket: bucket, access_key_id: access_key_id, secret_access_key: secret_access_key] =
      Application.get_env(:lild, :s3)
      |> Keyword.take([:bucket, :access_key_id, :secret_access_key])

    policy = policy(bucket, filename, mimetype)

    %{
      key: filename,
      'Content-Type': mimetype,
      acl: "private",
      success_action_status: "201",
      action: "https://s3.amazonaws.com/#{bucket}",
      AWSAccessKeyId: access_key_id,
      policy: policy,
      signature: hmac_sha1(secret_access_key, policy)
    }
  end

  defp now_plus(seconds) do
    Time.utc_now()
    |> Time.add(seconds, :second)
    |> Time.to_iso8601()
  end

  defp hmac_sha1(secret, message) do
    :crypto.hmac(:sha, secret, message) |> Base.encode64
  end

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
end
