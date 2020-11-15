defmodule ReviewsScraper.CLITest do
  use ReviewsScraper.TestCase

  import ExUnit.CaptureIO
  import Mock

  alias ReviewsScraper.CLI
  alias ReviewsScraper.Models.Review

  describe "CLI - tests" do
    setup :setup_reviews_html
    setup :setup_review

    test "main/1", %{ reviews_html: reviews_html, review: review } do
      with_mock(HTTPoison, [ get: fn _url -> {:ok, %HTTPoison.Response{ status_code: 200, body: reviews_html }} end]) do
        assert output = capture_io(fn ->
          CLI.main(%{})
        end)

        assert {:ok, reviews} = Poison.decode(output, keys: :atoms)

        expected_review = %{
          author: review.author,
          content: review.content,
          date: Date.to_iso8601(review.date),
          employees_reviews: Enum.map(review.employees_reviews, fn %{ name: name, rating: rating} -> %{name: name, rating: rating} end),
          individual_rates: Enum.map(review.individual_rates, fn %{ name: name, rating: rating} -> %{name: name, rating: rating} end),
          rating: review.rating,
          score: review.score

        }

        assert [
          ^expected_review,
          ^expected_review,
          ^expected_review
        ] = reviews
      end
    end

  end

  describe "CLI - overly positive reviews selection" do

    test "get_three_most_overly_positive/1 - select correct reviews ordered by date" do
      reviews = [
        %Review{ date: ~D[2020-11-14], score: 500 },
        %Review{ date: ~D[2020-11-15], score: 500 },
        %Review{ date: ~D[2020-11-13], score: 500 },
        %Review{ date: ~D[2020-11-12], score: 500 },
        %Review{ date: ~D[2020-11-05], score: 500 }
      ]

      assert [
        %Review{ date: ~D[2020-11-15], score: 500 },
        %Review{ date: ~D[2020-11-14], score: 500 },
        %Review{ date: ~D[2020-11-13], score: 500 }
      ] == CLI.get_three_most_overly_positive(reviews)
    end

    test "get_three_most_overly_positive/1 - select correct reviews ordered by score" do
      reviews = [
        %Review{ date: ~D[2020-11-14], score: 500 },
        %Review{ date: ~D[2020-11-14], score: 550 },
        %Review{ date: ~D[2020-11-14], score: 450 },
        %Review{ date: ~D[2020-11-14], score: 400 },
        %Review{ date: ~D[2020-11-14], score: 600 }
      ]

      assert [
        %Review{ date: ~D[2020-11-14], score: 600 },
        %Review{ date: ~D[2020-11-14], score: 550 },
        %Review{ date: ~D[2020-11-14], score: 500 }
      ] == CLI.get_three_most_overly_positive(reviews)
    end

    test "get_three_most_overly_positive/1 - select correct reviews ordered by score and date" do
      reviews = [
        %Review{ date: ~D[2020-11-14], score: 500 },
        %Review{ date: ~D[2020-11-14], score: 650 },
        %Review{ date: ~D[2020-11-14], score: 450 },
        %Review{ date: ~D[2020-11-10], score: 650 },
        %Review{ date: ~D[2020-11-12], score: 600 }
      ]

      assert [
        %Review{ date: ~D[2020-11-14], score: 650 },
        %Review{ date: ~D[2020-11-10], score: 650 },
        %Review{ date: ~D[2020-11-12], score: 600 }
      ] == CLI.get_three_most_overly_positive(reviews)
    end

  end

end
