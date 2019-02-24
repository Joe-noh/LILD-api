defmodule LILD.Fixture do
  def merge(overwrite, default) do
    Map.merge(default, overwrite)
  end
end
