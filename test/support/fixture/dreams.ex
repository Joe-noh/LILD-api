defmodule LILD.Fixture.Dreams do
  def dream(attrs \\ %{}) do
    LILD.Fixture.merge(attrs, %{
      body: Ffaker.En.Lorem.sentence(),
      date: Date.utc_today(),
      secret: Enum.random([true, false]),
      draft: Enum.random([true, false])
    })
  end

  def tag(attrs \\ %{}) do
    LILD.Fixture.merge(attrs, %{
      name: Ffaker.En.Lorem.word()
    })
  end
end
