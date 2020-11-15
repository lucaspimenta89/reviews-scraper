defmodule ReviewsScraper.CLI do

  alias ReviewsScraper.ReviewsPrinter

  def get_three_most_overly_positive(reviews) do
    reviews
    |> Enum.sort_by(& &1.date, {:desc, Date})
    |> Enum.sort_by(& &1.score, :desc)
    |> Enum.take(3)
  end

  def main(_args) do
    ReviewsScraper.Scraper.get_reviews()
    |> get_three_most_overly_positive()
    |> ReviewsPrinter.print_reviews()
  end
end
