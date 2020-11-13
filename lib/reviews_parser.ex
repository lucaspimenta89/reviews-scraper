defmodule ReviewsScraper.ReviewsParser do
  import ReviewsScraper.HtmlParser

  def get_document_reviews(html) when is_binary(html) do
    with {:ok, document} <- parse_html_string(html) do
      get_html_document_reviews(document)
    end
  end

  defp get_html_document_reviews(html_doc) do
    html_doc
    |> find_nodes(".review-entry")
    |> Enum.map(&get_review/1)
  end

  def get_review(review_fragment) do
    %{
      rating: get_review_rating(review_fragment),
      author: get_review_author(review_fragment),
      content: get_review_content(review_fragment),
      individual_rates: get_individual_rates(review_fragment),
      employees_reviews: get_employees_reviews(review_fragment)
    }
  end

  defp get_review_rating(review_fragment) do
    review_fragment
    |> get_node_class_attribute("div.dealership-rating > div:first-child")
    |> get_rating_from_classes()
  end

  def get_rating_from_classes([classes]) when is_binary(classes) do
    classes
    |> String.split()
    |> Enum.find(fn class -> !String.starts_with?(class, "rating-static") && String.starts_with?(class, "rating-") end)
    |> get_rating_value()
  end

  def get_rating_value("rating-" <> value) do
    {int_part, _ } = Integer.parse(value)
    int_part
  end
  def get_rating_value(_), do: 0

  def get_review_author(review_fragment) do
    review_fragment
    |> get_node_text("div.review-wrapper > div:first-child > span")
    |> parse_author_name()
  end

  def parse_author_name("- " <> author), do: author
  def parse_author_name(_), do: ""

  def get_review_content(review_fragment) do
    review_fragment
    |> get_node_text("p.review-content")
  end

  def get_individual_rates(review_fragment) do
    review_fragment
    |> find_nodes("div.review-ratings-all > div.table > div.tr")
    |> Enum.map(&get_individual_rate/1)
  end
  def get_individual_rate(rate_fragment) do
    rate_name = rate_fragment
    |> get_node_text("div:first-child")

    rate_value = get_individual_rate_value(rate_name, rate_fragment)

    %{
      rate_name: rate_name,
      rate_value: rate_value
    }
  end

  def get_individual_rate_value(_rate_label = "Recommend Dealer", rate_fragment) do
    rate_fragment
    |> get_node_text("div:nth-child(2)")
    |> String.replace(~r/[^A-za-z]/, "")
    |> String.downcase()
  end

  def get_individual_rate_value(_rate_label, rate_fragment) do
    rate_fragment
    |> get_node_class_attribute("div.rating-static-indv")
    |> get_rating_from_classes()
  end

  def get_employees_reviews(review_rating) do
    review_rating
    |> find_nodes("div.employees-wrapper > div.review-employee")
    |> Enum.map(&get_employee_review/1)
  end

  def get_employee_review(employee_review_fragment) do
    employee_name = employee_review_fragment
      |> get_node_text("a.tagged-emp")
      |> String.trim()

    employee_rate = employee_review_fragment
      |> get_node_class_attribute("div.employee-rating-badge-sm > div > div.rating-static")
      |> get_rating_from_classes()

    %{
      employee_name: employee_name,
      employee_rate: employee_rate
    }
  end

end
