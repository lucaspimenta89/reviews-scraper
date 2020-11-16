defmodule ReviewsScraper.Scraper do
  @moduledoc """
  Download the HTML of the review pages and parse it to a list of %Reviews{}
  """
  @pages_range 1..5

  @doc """
   Parses the reviews HTML pages to [%Reviews{}]

   # Examples
   iex> ReviewsScraper.Scraper.get_reviews()
   [%Reviews{}]
  """
  def get_reviews() do
    @pages_range
    |> Task.async_stream(&process_page/1)
    |> Enum.reduce([], &concatenate_reviews/2)
  end

  @doc """
  Concatenates the reviews from all pages
  """
  def concatenate_reviews({:ok, reviews}, acc), do: Enum.concat(acc, reviews)

  @doc """
  Download a review page and parses it

  ## Examples

  iex> ReviewsScraper.Scraper.process_page(1)
  [%Review{}, ...]
  """
  def process_page(page_number) do
    with {:ok, url} <- get_url("/page#{page_number}/?filter=&__optvLead=0#link"),
         {:response, {:ok, %HTTPoison.Response{status_code: 200, body: body}}} <-
           {:response, HTTPoison.get(url)} do
      ReviewsScraper.ReviewsParser.get_document_reviews(body)
    else
      {:response, {:error, _}} ->
        raise("Unable to download reviews")
    end
  end

  @doc """
    Get the URL for a page number

    ## Examples
    iex> ReviewsScraper.Scraper.get_url("/page1/?filter=&__optvLead=0#link")
    {:ok, "https://www.dealerrater.com/dealer/McKaig-Chevrolet-Buick-A-Dealer-For-The-People-dealer-reviews-23685/page1/?filter=&__optvLead=0#link"}
  """
  def get_url(search) do
    mc_kaig_url = Application.fetch_env!(:reviews_scraper, ReviewsScraper)[:mc_kaig_url]
    {:ok, "#{mc_kaig_url}/#{search}"}
  end
end
