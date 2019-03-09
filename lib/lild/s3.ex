defmodule LILD.S3 do
  def presigned_url(user, prefix, mimetype) do
    if valid_mimetype?(mimetype) do
      key = Path.join([prefix, user.id, unique_key(mimetype)])
      signature("private", key, mimetype)
    else
      :error
    end
  end

  defp valid_mimetype?("image/jpeg"), do: true
  defp valid_mimetype?("image/png"), do: true
  defp valid_mimetype?(_), do: false

  defp unique_key(mimetype) do
    Ecto.ULID.generate() <> mime_to_ext(mimetype)
  end

  defp mime_to_ext("image/jpeg"), do: ".jpg"
  defp mime_to_ext("image/png"), do: ".png"
  defp mime_to_ext(mimetype), do: raise("Unsuppoerted mimetype: #{mimetype}")

  def signature(acl, key, content_type) do
    [region: region, bucket: bucket, access_key_id: access_key_id, secret_access_key: secret_access_key] =
      Application.get_env(:lild, :s3)
      |> Keyword.take([:region, :bucket, :access_key_id, :secret_access_key])

    now = %DateTime{DateTime.utc_now() | second: 0, microsecond: {0, 0}}
    date = current_date(now)

    algorithm = "AWS4-HMAC-SHA256"
    credential = "#{access_key_id}/#{date}/#{region}/s3/aws4_request"
    timestamp = current_timestamp(now)
    encryption = "AES256"

    conditions = [
      %{"acl" => acl},
      %{"key" => key},
      %{"bucket" => bucket},
      %{"Content-Type" => content_type},
      ["content-length-range", "0", Integer.to_string(1024 * 1024)],
      %{"x-amz-algorithm" => algorithm},
      %{"x-amz-credential" => credential},
      %{"x-amz-date" => timestamp},
      %{"x-amz-server-side-encryption" => encryption}
    ]

    encoded_policy = encoded_policy(now, conditions)
    encoded_signature = encoded_signature(secret_access_key, date, region, encoded_policy)

    IO.puts ~s"""
      curl -v -X POST \\
        -F Content-Type="#{content_type}"
        -F acl="#{acl}" \\
        -F key="#{key}" \\
        -F policy="#{encoded_policy}" \\
        -F x-amz-algorithm="AWS4-HMAC-SHA256" \\
        -F x-amz-credential="#{access_key_id}/#{date}/#{region}/s3/aws4_request" \\
        -F x-amz-date="#{timestamp}" \\
        -F x-amz-signature="#{encoded_signature}" \\
        -F x-amz-server-side-encryption="AES256" \\
        -F "file=@image.jpg" \\
        https://#{bucket}.s3.amazonaws.com/
    """
  end

  defp current_date(now) do
    now |> Date.to_iso8601(:basic)
  end

  defp current_timestamp(now) do
    %DateTime{now | microsecond: {0, 0}} |> DateTime.to_iso8601(:basic)
  end

  defp encoded_policy(now, conditions) do
    expiration = now |> DateTime.add(60, :second) |> DateTime.to_iso8601()

    %{expiration: expiration, conditions: conditions}
    |> Jason.encode!()
    |> Base.encode64()
  end

  def encoded_signature(secret_access_key, date, region, encoded_policy) do
    "AWS4#{secret_access_key}"
    |> hmac(date)
    |> hmac(region)
    |> hmac("s3")
    |> hmac("aws4_request")
    |> hmac(encoded_policy)
    |> Base.encode16(case: :lower)
  end

  defp hmac(key, data) do
    :crypto.hmac(:sha256, key, data)
  end
end
