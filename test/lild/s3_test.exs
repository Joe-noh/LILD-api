defmodule LILD.S3Test do
  use LILD.DataCase, async: true

  setup :create_user

  describe "presign_for_avatar" do
    test "S3のURLとアップロードに必要なフィールドを返す", %{user: user} do
      {:ok, presign} = LILD.S3.presign_for_avatar(user, "image/jpeg")

      assert presign.url == "https://lild-dev.s3.amazonaws.com/"
      assert presign.fields["Content-Type"] == "image/jpeg"
    end

    test "対応していないmimetypeには:errorを返す", %{user: user} do
      assert :error == LILD.S3.presign_for_avatar(user, "image/webp")
      assert :error == LILD.S3.presign_for_avatar(user, "application/json")
      assert :error == LILD.S3.presign_for_avatar(user, "binary/octet-stream")
    end
  end

  defp create_user(_) do
    LILD.Accounts.create_user(Fixture.Accounts.user(), Fixture.Accounts.social_account())
  end
end
