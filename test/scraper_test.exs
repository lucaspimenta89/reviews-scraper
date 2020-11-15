defmodule ReviewsScraper.ScraperTest do
  use ReviewsScraper.TestCase

  import Mock

  alias ReviewsScraper.Scraper

  describe "Scraper - tests" do
    setup :setup_reviews_html
    setup :setup_review

    test "get_reviews/0", %{ reviews_html: reviews_html, review: review } do
      with_mock(HTTPoison, [ get: fn _url -> {:ok, %HTTPoison.Response{ status_code: 200, body: reviews_html }} end]) do
        assert [
          ^review,
          ^review,
          ^review,
          ^review,
          ^review
        ] = Scraper.get_reviews()
      end
    end

    test "get_reviews/0 error handling" do
      with_mock(HTTPoison, [ get: fn _url -> {:error, %HTTPoison.Error{}} end]) do

        assert_raise RuntimeError, "Unable to download reviews", fn ->
          Scraper.process_page(1)
        end

      end
    end
  end
end
