defmodule LILD.S3 do
  def presigned_url(user, prefix, mimetype) do
    if valid_mimetype?(mimetype) do
      bucket = Application.get_env(:ex_aws, :bucket)
      key = Path.join([prefix, user.id, unique_key(mimetype)])
      query = ['Content-Type': mimetype]

      ExAws.Config.new(:s3)
      |> ExAws.S3.presigned_url(:put, bucket, key, virtual_host: true, expires_in: 60, query_params: query)
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
  defp mime_to_ext(mimetype), do: raise "Unsuppoerted mimetype: #{mimetype}"
end
