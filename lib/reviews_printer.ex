defmodule ReviewsScraper.ReviewsPrinter do
  @moduledoc """
  Provide print_reviews/1 to print the review to the console
  """

  @doc """
    Print a list of reviews to the console as JSON

    ## Examples
    iex> ReviewsScraper.ReviewsPrinter.print_reviews([%ReviewsScraper.Models.Review{ rating: 50 }])
    [
      {
        "rating": 50
      }
    ]
  """
  def print_reviews(reviews) when is_list(reviews) do
    reviews
    |> Poison.encode!(pretty: true)
    |> IO.puts()
  end

end
