defmodule LILD.S3Test do
  use ExUnit.Case, async: true

  test "run" do
    IO.inspect(LILD.S3.signature("private", "image.jpg", "image/jpeg"))
  end
end
