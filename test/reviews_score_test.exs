defmodule ReviewsScraper.ReviewsScoreTest do
  use ReviewsScraper.TestCase

  alias ReviewsScraper.Models.{IndividualReview, EmployeeReview}

  alias ReviewsScraper.ReviewsScore

  describe "ReviewsScore - Tests" do

    test "sum_individual_rates/2 - with \"yes\" as rating" do
      assert 50 == ReviewsScore.sum_individual_rates(0, [
        %IndividualReview{ rating: "yes" }
      ])
    end

    test "sum_individual_rates/2 - with \"no\" as rating" do
      assert 0 == ReviewsScore.sum_individual_rates(0, [
        %IndividualReview{ rating: "no" }
      ])
    end

    test "sum_individual_rates/2 - with unrecognized rating" do
      assert 0 == ReviewsScore.sum_individual_rates(0, [
        %IndividualReview{ rating: "abcd" }
      ])
    end

    test "sum_individual_rates/2 - with numeric rating" do
      assert 50 == ReviewsScore.sum_individual_rates(0, [
        %IndividualReview{ rating: 50 }
      ])
    end

    test "sum_employees_rates/2 - with numeric rating" do
      assert 50 == ReviewsScore.sum_employees_rates(0, [
        %EmployeeReview{ rating: 50 }
      ])
    end

    test "sum_employees_rates/2 - with not a numeric rating" do
      assert 0 == ReviewsScore.sum_employees_rates(0, [
        %EmployeeReview{ rating: "not a number" }
      ])
    end

  end
end
