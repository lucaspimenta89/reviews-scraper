defmodule ReviewsScraper.TestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import ReviewsScraper.TestsSetups
    end
  end
end
