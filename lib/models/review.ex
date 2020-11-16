defmodule ReviewsScraper.Models.Review do
  defstruct rating: 0,
            date: nil,
            author: "",
            content: "",
            individual_rates: [],
            employees_reviews: [],
            score: 0
end
