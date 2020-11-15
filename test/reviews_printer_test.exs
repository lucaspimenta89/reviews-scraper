defmodule ReviewsScraper.ReviewsPrinterTest do
  use ReviewsScraper.TestCase

  import ExUnit.CaptureIO

  alias ReviewsScraper.ReviewsPrinter

  describe "ReviewsPrinter - tests" do
    setup :setup_review

    test "print_reviews/1", %{ review: review } do
      assert output = capture_io(fn ->
        ReviewsPrinter.print_reviews([review])
      end)

      assert {:ok, [printed_review]} = Poison.decode(output, keys: :atoms)

      assert printed_review == %{
        author: review.author,
        content: review.content,
        date: Date.to_iso8601(review.date),
        employees_reviews: Enum.map(review.employees_reviews, fn %{ name: name, rating: rating} -> %{name: name, rating: rating} end),
        individual_rates: Enum.map(review.individual_rates, fn %{ name: name, rating: rating} -> %{name: name, rating: rating} end),
        rating: review.rating,
        score: review.score
      }

    end

  end
end
