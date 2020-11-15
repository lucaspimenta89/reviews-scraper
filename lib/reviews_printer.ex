defmodule ReviewsScraper.ReviewsPrinter do

  def print_reviews([review | tail]) do
    IO.write("#============\n")
    IO.write("# Review: #{review.content}\n")
    IO.write("# Author: #{review.author}\n")
    IO.write("# Date: #{Date.to_iso8601(review.date)}\n")
    IO.write("# Rating: #{review.rating}\n")
    IO.write("# Score: #{review.score}\n")

    IO.write("# Individual Rates:\n")
    print_individual_rates(review.individual_rates)

    IO.write("# Employees Rates:\n")
    print_employees_rates(review.employees_reviews)

    print_reviews(tail)
  end

  def print_reviews([]), do: IO.write("\n")

  def print_individual_rates([individual_rate | tail]) do
    IO.write("- #{individual_rate.name}: #{individual_rate.rating}\n")
    print_individual_rates(tail)
  end

  def print_individual_rates([]), do: IO.write("\n")

  def print_employees_rates([employee_rate | tail]) do
    IO.write("- #{employee_rate.name}: #{employee_rate.rating}\n")
    print_employees_rates(tail)
  end

  def print_employees_rates([]), do: IO.write("\n")

end
