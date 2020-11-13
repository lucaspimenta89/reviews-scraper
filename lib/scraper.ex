defmodule ReviewsScraper.Scraper do

  @pages_range 1..5

  def fetch_first_five_pages() do
    @pages_range
    |> Task.async_stream(&process_page/1)
    |> Enum.reduce([], &concatenate_reviews/2)
  end

  def concatenate_reviews({:ok, reviews}, acc), do: Enum.concat(acc, reviews)
  def concatenate_reviews({:error, reason}, _acc), do: raise(reason)

  def process_page(page_number) do
    with {:ok, url} <- get_url("/page#{page_number}/?filter=&__optvLead=0#link"),
         {:response, {:ok, %HTTPoison.Response{ status_code: 200, body: body }}} <- {:response, HTTPoison.get(url)} do
      ReviewsScraper.ReviewsParser.get_document_reviews(body)
    else
      {:response, {:error, _ }} ->
        {:error, :request_failed}
    end
  end

  def get_url(search) do
    mc_kaig_url = Application.fetch_env!(:reviews_scraper, ReviewsScraper)[:mc_kaig_url]
    {:ok, "#{mc_kaig_url}/#{search}"}
  end
end
