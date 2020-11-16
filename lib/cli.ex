defmodule ReviewsScraper.CLI do
  @moduledoc """
  Entrypoint of the application providing the main/1 function that performes the data fetching and selection of the reviews
  """
  alias ReviewsScraper.ReviewsPrinter

  @doc """
    Select the top three reviews with the bigest scores and are more recent

    ## Parameters

      - reviews: List of %ReviewsScraper.Models.Review{}

    ## Examples

      iex>  ReviewsScraper.CLI.get_three_most_overly_positive([
        %Review{ date: ~D[2020-11-14], score: 500 },
        %Review{ date: ~D[2020-11-14], score: 650 },
        %Review{ date: ~D[2020-11-14], score: 450 },
        %Review{ date: ~D[2020-11-10], score: 650 },
        %Review{ date: ~D[2020-11-12], score: 600 }
      ])

      [
        %Review{ date: ~D[2020-11-14], score: 650 },
        %Review{ date: ~D[2020-11-10], score: 650 },
        %Review{ date: ~D[2020-11-12], score: 600 }
      ]
  """
  def get_three_most_overly_positive(reviews) do
    reviews
    |> Enum.sort_by(& &1.date, {:desc, Date})
    |> Enum.sort_by(& &1.score, :desc)
    |> Enum.take(3)
  end

  @doc """
   Fetch the reviews, select the top three overly rated and print it into console as JSON
  """
  def main(_args) do
    ReviewsScraper.Scraper.get_reviews()
    |> get_three_most_overly_positive()
    |> ReviewsPrinter.print_reviews()
  end
end
