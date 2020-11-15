defmodule ReviewsScraper.ReviewsScore do
  @moduledoc """
  Calculate the score of a review
  """

  alias ReviewsScraper.Models.{Review, IndividualReview, EmployeeReview}

  @doc """
    Calculate review score and set the "score" field of the %Review{}

    ## Examples
    iex> ReviewsScraper.ReviewsScore.get_review_score(%Review{
      rating: 50,
      individual_rates: [%IndividualReview{ rating: 50 }],
      employees_reviews: [%EmployeeReview{ rating: 50 }]
    })
    %Review{
      rating: 50,
      individual_rates: [%IndividualReview{ rating: 50 }],
      employees_reviews: [%EmployeeReview{ rating: 50 }],
      score: 150
    }
  """
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


  @doc """
    Sum all individual rates of a Review recursively

    ## Examples
    iex> sum_individual_rates(0, [%IndividualReview{ rating: "yes" }])
    50

    iex> sum_individual_rates(50, [%IndividualReview{ rating: 50 }])
    100

    iex> sum_individual_rates(0, [%IndividualReview{ rating: "not a number" }])
    0

    iex> sum_individual_rates(0, [])
    0

  """
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

  @doc """
    Sum all employees rates

    ## Examples

    iex> sum_employees_rates(0, [%EmployeeReview{ rating: 50 }])
    50

    iex> sum_employees_rates(0, [%EmployeeReview{ rating: "not a number" }])
    0

    iex> sum_employees_rates(0, [])
    0
  """
  def sum_employees_rates(score, [%EmployeeReview{ rating: rating } | tail]) when is_number(rating) do
    sum_employees_rates(score + rating, tail)
  end

  def sum_employees_rates(score, [%EmployeeReview{} | tail]) do
    sum_employees_rates(score, tail)
  end

  def sum_employees_rates(score, []), do: score

end
