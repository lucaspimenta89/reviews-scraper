defmodule ReviewsScraper.ReviewsScore do

  alias ReviewsScraper.Models.{Review, IndividualReview, EmployeeReview}

  def get_review_score(%Review{
    rating: rating,
    individual_rates: individual_rates,
    employees_reviews: employees_reviews
  } = review) do
    score = rating
    |> sum_individual_rates(individual_rates)
    |> sum_employees_rates(employees_reviews)

    Map.put(review, :score, score)
  end

  def sum_individual_rates(score, [%IndividualReview{ rating: "yes" } | tail]) do
    sum_individual_rates(score + 50, tail)
  end

  def sum_individual_rates(score, [%IndividualReview{ rating: rating } | tail]) when is_number(rating) do
    sum_individual_rates(score + rating, tail)
  end

  def sum_individual_rates(score, [%IndividualReview{} | tail]) do
    sum_individual_rates(score, tail)
  end

  def sum_individual_rates(score, []), do: score

  def sum_employees_rates(score, [%EmployeeReview{ rating: rating } | tail]) when is_number(rating) do
    sum_employees_rates(score + rating, tail)
  end

  def sum_employees_rates(score, [%EmployeeReview{} | tail]) do
    sum_employees_rates(score, tail)
  end

  def sum_employees_rates(score, []), do: score

end
