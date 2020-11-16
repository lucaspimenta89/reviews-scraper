defmodule ReviewsScraper.ReviewsParserTest do
  use ReviewsScraper.TestCase

  alias ReviewsScraper.Models.Review
  alias ReviewsScraper.ReviewsParser

  describe "ReviewsParser - tests for single review" do
    setup :setup_review_html_tree
    setup :setup_review

    test "get_review_rating/2", %{review_html_tree: review_html_tree, review: %{rating: rating}} do
      assert %Review{rating: ^rating} =
               ReviewsParser.get_review_rating(%Review{}, review_html_tree)
    end

    test "get_review_date/2", %{review_html_tree: review_html_tree, review: %{date: date}} do
      assert %Review{date: ^date} = ReviewsParser.get_review_date(%Review{}, review_html_tree)
    end

    test "get_review_author/2", %{review_html_tree: review_html_tree, review: %{author: author}} do
      assert %Review{author: ^author} =
               ReviewsParser.get_review_author(%Review{}, review_html_tree)
    end

    test "get_review_content/2", %{
      review_html_tree: review_html_tree,
      review: %{content: content}
    } do
      assert %Review{content: ^content} =
               ReviewsParser.get_review_content(%Review{}, review_html_tree)
    end

    test "get_individual_rates/2", %{
      review_html_tree: review_html_tree,
      review: %{individual_rates: individual_rates}
    } do
      assert %Review{individual_rates: ^individual_rates} =
               ReviewsParser.get_individual_rates(%Review{}, review_html_tree)
    end

    test "get_employees_reviews/2", %{
      review_html_tree: review_html_tree,
      review: %{employees_reviews: expected_employees_reviews}
    } do
      assert %Review{employees_reviews: ^expected_employees_reviews} =
               ReviewsParser.get_employees_reviews(%Review{}, review_html_tree)
    end

    test "get_review/1", %{review_html_tree: review_html_tree, review: review} do
      assert review == ReviewsParser.get_review(review_html_tree)
    end
  end

  describe "ReviewsParser - tests for full page of reviews" do
    setup :setup_reviews_html
    setup :setup_review

    test "get_document_reviews/1", %{reviews_html: reviews_html, review: review} do
      assert [review] == ReviewsParser.get_document_reviews(reviews_html)
    end
  end
end
