defmodule ReviewsScraper.ReviewsPrinter do

  def print_reviews(reviews) do
    reviews
    |> Poison.encode!(pretty: true)
    |> IO.puts()
  end

end
