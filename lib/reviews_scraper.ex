defmodule ReviewsScraper.CLI do
  def main(_args) do
    reviews = ReviewsScraper.Scraper.fetch_first_five_pages()

    IO.inspect(reviews)
    IO.puts length(reviews)
  end
end
