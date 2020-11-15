defmodule ReviewsScraper.ReviewsParser do
  import ReviewsScraper.HtmlParser

  alias ReviewsScraper.ReviewsScore
  alias ReviewsScraper.DateParser

  alias ReviewsScraper.Models.{Review, IndividualReview, EmployeeReview}

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
    %Review{}
    |> get_review_rating(review_fragment)
    |> get_review_date(review_fragment)
    |> get_review_author(review_fragment)
    |> get_review_content(review_fragment)
    |> get_individual_rates(review_fragment)
    |> get_employees_reviews(review_fragment)
    |> ReviewsScore.get_review_score()
  end

  defp get_review_rating(%Review{} = review, review_fragment) do
    rating = review_fragment
    |> get_node_class_attribute("div.dealership-rating > div:first-child")
    |> get_rating_from_classes()

    Map.put(review, :rating, rating)
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

  def get_review_date(%Review{} = review, review_fragment) do
    date = review_fragment
    |> get_node_text("div.review-date > div:first-child")
    |> DateParser.parse_date!()

    Map.put(review, :date, date)
  end

  def get_review_author(%Review{} = review, review_fragment) do
    author = review_fragment
    |> get_node_text("div.review-wrapper > div:first-child > span")
    |> parse_author_name()

    Map.put(review, :author, author)
  end

  def parse_author_name("- " <> author), do: author
  def parse_author_name(_), do: ""

  def get_review_content(%Review{} = review, review_fragment) do
    content = review_fragment
    |> get_node_text("p.review-content")

    Map.put(review, :content, content)
  end

  def get_individual_rates(%Review{} = review, review_fragment) do
    individual_rates = review_fragment
    |> find_nodes("div.review-ratings-all > div.table > div.tr")
    |> Enum.map(&get_individual_rate/1)

    Map.put(review, :individual_rates, individual_rates)
  end
  def get_individual_rate(rate_fragment) do
    %IndividualReview{}
    |> get_individual_rate_name(rate_fragment)
    |> get_individual_rate_value(rate_fragment)
  end

  def get_individual_rate_name(%IndividualReview{} = individual_rate, rate_fragment) do
    rate_name = rate_fragment
    |> get_node_text("div:first-child")

    Map.put(individual_rate, :name, rate_name)
  end

  def get_individual_rate_value(%IndividualReview{ name: "Recommend Dealer" } = individual_rate, rate_fragment) do
    rate_value = rate_fragment
    |> get_node_text("div:nth-child(2)")
    |> String.replace(~r/[^A-za-z]/, "")
    |> String.downcase()

    Map.put(individual_rate, :rating, rate_value)
  end

  def get_individual_rate_value(%IndividualReview{} = individual_rate, rate_fragment) do
    rate_value = rate_fragment
    |> get_node_class_attribute("div.rating-static-indv")
    |> get_rating_from_classes()

    Map.put(individual_rate, :rating, rate_value)
  end

  def get_employees_reviews(%Review{} = review, review_rating) do
    employees_reviews = review_rating
    |> find_nodes("div.employees-wrapper > div.review-employee")
    |> Enum.map(&get_employee_review/1)

    Map.put(review, :employees_reviews, employees_reviews)
  end

  def get_employee_review(employee_review_fragment) do
    %EmployeeReview{}
    |> get_employee_review_name(employee_review_fragment)
    |> get_employee_review_rate(employee_review_fragment)
  end

  def get_employee_review_name(%EmployeeReview{} = employee_review, employee_review_fragment) do
    name = employee_review_fragment
      |> get_node_text("a.tagged-emp")
      |> String.trim()

    Map.put(employee_review, :name, name)
  end

  def get_employee_review_rate(%EmployeeReview{} = employee_review, employee_review_fragment) do
    rate = employee_review_fragment
      |> get_node_class_attribute("div.employee-rating-badge-sm > div > div.rating-static")
      |> get_rating_from_classes()

    Map.put(employee_review, :rating, rate)
  end

end
