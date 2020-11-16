defmodule ReviewsScraper.ReviewsParser do
  @moduledoc """
  Parses the HTML of a review page to a list of %ReviewsScraper.Models.Review{}
  """
  import ReviewsScraper.HtmlParser

  alias ReviewsScraper.ReviewsScore
  alias ReviewsScraper.DateParser

  alias ReviewsScraper.Models.{Review, IndividualReview, EmployeeReview}

  @doc """
    Parses review page to list of %Review{}

    ## Examples

    iex> ReviewsScraper.ReviewsParser.get_document_reviews("<html>..</html>")
    [%Review{}, %Review{}, ...]
  """
  def get_document_reviews(html) when is_binary(html) do
    with {:ok, document} <- parse_html_string(html) do
      get_reviews(document)
    end
  end

  @doc """
    Parses the reviews from a HTML document, looking for all DIV elements with class ".review-entry" and parses it to a list of %Review{}

    ## Examples
    iex> {:ok, html} = get_document_reviews("<html>..</html>")
    iex> get_reviews(html)
    [%Review{}, %Review{}, ...]
  """
  def get_reviews(html_doc) do
    html_doc
    |> find_nodes("div.review-entry")
    |> Enum.map(&get_review/1)
  end

  @doc """
    Parses an HTML fragment to a %Review{} and calculate the scores

    ## Examples
    iex> ReviewsScraper.ReviewsParser.get_review(<review_fragment>)
    %Review{}
  """
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

  @doc """
    Parses the review fragment, get the overall rating and set it to the "rating" field of an %Review{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
      <div class="dealership-rating">
        <div class="rating-static rating-50"></div>
          <div class="rating-static hidden-xs rating-50"></div>
          <div>SALES VISIT - NEW</div>
        </div>
      <div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_review_rating(%Review{}, review_fragment)
    %Review{ rating: 50 }
  """
  def get_review_rating(%Review{} = review, review_fragment) do
    rating =
      review_fragment
      |> get_node_class_attribute("div.dealership-rating > div:first-child")
      |> get_rating_from_classes()

    Map.put(review, :rating, rating)
  end

  @doc """
    Get the rating value from the number of stars displayed, it is controlled by the ".rating-*" class

    ## Examples
    iex> ReviewsScraper.ReviewsParser.get_rating_from_classes(["rating-static hidden-xs rating-50"])
    50
  """
  def get_rating_from_classes([classes]) when is_binary(classes) do
    classes
    |> String.split()
    |> Enum.find(fn class ->
      !String.starts_with?(class, "rating-static") && String.starts_with?(class, "rating-")
    end)
    |> get_rating_value()
  end

  @doc """
    Get the integer part of the class ".rating-*"

    ## Examples
    iex> ReviewsScraper.ReviewsParser.get_rating_value("rating-50")
    50

    iex> ReviewsScraper.ReviewsParser.get_rating_value("not a rating")
    0
  """
  def get_rating_value("rating-" <> value) do
    {int_part, _} = Integer.parse(value)
    int_part
  end

  def get_rating_value(_), do: 0

  @doc """
    Parses the review HTML fragment and get the review date and set it to the "date" field of an %Review{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
      <div class="review-date">
        <div>November 14, 2020</div>
      </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_review_date(%Review{}, review_fragment)
    %Review{ date: ~D[2020-11-14] }
  """
  def get_review_date(%Review{} = review, review_fragment) do
    {:ok, date} =
      review_fragment
      |> get_node_text("div.review-date > div:first-child")
      |> DateParser.parse_date()

    Map.put(review, :date, date)
  end

  @doc """
    Parses the review HTML fragment, get the author of the review and set it to the "author" field of an %Review{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
      <div class="review-wrapper">
        <div>
          <h3>"I came here for the friendly but low pressure service...."</h3>
          <span>- lisapantlin</span>
        </div>
      </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_review_author(%Review{}, review_fragment)
    %Review{ author: "lisapantlin" }
  """
  def get_review_author(%Review{} = review, review_fragment) do
    author =
      review_fragment
      |> get_node_text("div.review-wrapper > div:first-child > span")
      |> parse_author_name()

    Map.put(review, :author, author)
  end

  @doc """
  Parses the author name
  """
  def parse_author_name("- " <> author), do: author
  def parse_author_name(_), do: ""

  @doc """
    Parses the review HTML fragment, get the content of the review and set it to the "content" field of an %Review{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
      <div class="review-wrapper">
        <div>
          <h3>"I came here for the friendly but low pressure service...."</h3>
          <span>- lisapantlin</span>
        </div>

        <div>
          <div>
            <p class="review-content">
              [REVIEW CONTENT]
            </p>
            <a id="7565083">Read More</a>
          </div>
        </div>
      </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_review_content(%Review{}, review_fragment)
    %Review{ content: "[REVIEW CONTENT]" }
  """
  def get_review_content(%Review{} = review, review_fragment) do
    content =
      review_fragment
      |> get_node_text("p.review-content")
      |> String.trim()

    Map.put(review, :content, content)
  end

  @doc """
    Parses the review HTML individual rates fragment and set the "individual_rates" field of an %Review{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="review-ratings-all">
          <div class="table">
            <div class="tr">
              <div>Customer Service</div>
              <div class="rating-static-indv rating-50"></div>
            </div>
          </div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_individual_rates(%Review{}, review_fragment)
    %Review{ individual_rates: [%IndividualReview{ name: "Customer Service", rating: 50}] }
  """
  def get_individual_rates(%Review{} = review, review_fragment) do
    individual_rates =
      review_fragment
      |> find_nodes("div.review-ratings-all > div.table > div.tr")
      |> Enum.map(&get_individual_rate/1)

    Map.put(review, :individual_rates, individual_rates)
  end

  @doc """
    Parses an individual rate fragment to %IndividualReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="tr">
          <div>Customer Service</div>
          <div class="rating-static-indv rating-50"></div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_individual_rate(review_fragment)
   %IndividualReview{ name: "Customer Service", rating: 50}
  """
  def get_individual_rate(rate_fragment) do
    %IndividualReview{}
    |> get_individual_rate_name(rate_fragment)
    |> get_individual_rate_value(rate_fragment)
  end

  @doc """
    Get the name part of a individual rate fragment,  and set it to the "name" field of an %IndividualReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="tr">
          <div>Customer Service</div>
          <div class="rating-static-indv rating-50"></div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_individual_rate_name(%IndividualReview{}, review_fragment)
   %IndividualReview{ name: "Customer Service"}
  """
  def get_individual_rate_name(%IndividualReview{} = individual_rate, rate_fragment) do
    rate_name =
      rate_fragment
      |> get_node_text("div:first-child")

    Map.put(individual_rate, :name, rate_name)
  end

  @doc """
    Get the value part of an individual rate fragment  and set it to the "rating" field of an %IndividualReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="tr">
          <div>Recommend Dealer</div>
          <div>Yes</div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_individual_rate_value(%IndividualReview{ name: "Recommend Dealer" }, review_fragment)
    %IndividualReview{  name: "Recommend Dealer", rating: "yes" }

    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="tr">
          <div>Customer Service</div>
          <div class="rating-static-indv rating-50"></div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_individual_rate_value(%IndividualReview{ name: "Customer Service" }, review_fragment)
    %IndividualReview{  name: "Customer Service", rating: 50 }
  """
  def get_individual_rate_value(
        %IndividualReview{name: "Recommend Dealer"} = individual_rate,
        rate_fragment
      ) do
    rate_value =
      rate_fragment
      |> get_node_text("div:nth-child(2)")
      |> String.replace(~r/[^A-za-z]/, "")
      |> String.downcase()

    Map.put(individual_rate, :rating, rate_value)
  end

  def get_individual_rate_value(%IndividualReview{} = individual_rate, rate_fragment) do
    rate_value =
      rate_fragment
      |> get_node_class_attribute("div.rating-static-indv")
      |> get_rating_from_classes()

    Map.put(individual_rate, :rating, rate_value)
  end

  @doc """
    Parses the review HTML employees rate fragment to  a list of %EmployeeReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="employees-wrapper">
          <div>Employees Worked With</div>
            <div class="review-employee">
              <div class="table">
                <div></div>
                <div>
                  <a class="tagged-emp">
                    Adrian "AyyDee" Cortes
                  </a>
                  <div>
                    <div class="relative employee-rating-badge-sm">
                      <div>
                        <span >5.0</span>
                        <div class="rating-static rating-50"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_employees_reviews(%Review{}, review_fragment)
    %Review{
      employees_reviews: [%EmployeeReview{ name: "Adrian "AyyDee" Cortes", rating: 50 }]
    }
  """
  def get_employees_reviews(%Review{} = review, review_rating) do
    employees_reviews =
      review_rating
      |> find_nodes("div.employees-wrapper > div.review-employee")
      |> Enum.map(&get_employee_review/1)

    Map.put(review, :employees_reviews, employees_reviews)
  end

  @doc """
    Parses a employee rate fragment to  %EmployeeReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="review-employee">
          <div class="table">
            <div></div>
            <div>
              <a class="tagged-emp">
                Adrian "AyyDee" Cortes
              </a>
              <div>
                <div class="relative employee-rating-badge-sm">
                  <div>
                    <span >5.0</span>
                    <div class="rating-static rating-50"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_employee_review(review_fragment)
    %EmployeeReview{ name: "Adrian "AyyDee" Cortes", rating: 50 }
  """
  def get_employee_review(employee_review_fragment) do
    %EmployeeReview{}
    |> get_employee_review_name(employee_review_fragment)
    |> get_employee_review_rate(employee_review_fragment)
  end

  @doc """
    Get the name part of an employee rate fragment, and set it to the "name" field of a %EmployeeReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="review-employee">
          <div class="table">
            <div></div>
            <div>
              <a class="tagged-emp">
                Adrian "AyyDee" Cortes
              </a>
              <div>
                <div class="relative employee-rating-badge-sm">
                  <div>
                    <span >5.0</span>
                    <div class="rating-static rating-50"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_employee_review_name(%EmployeeReview{}, review_fragment)
    %EmployeeReview{ name: "Adrian "AyyDee" Cortes" }
  """
  def get_employee_review_name(%EmployeeReview{} = employee_review, employee_review_fragment) do
    name =
      employee_review_fragment
      |> get_node_text("a.tagged-emp")
      |> String.trim()

    Map.put(employee_review, :name, name)
  end

  @doc """
    Get the value part of an employee rate fragment and set the "rating" field of a %EmployeeReview{}

    ## Examples
    iex> {:ok, review_fragment} = Floki.parse_fragment(
      \"""
        <div class="review-employee">
          <div class="table">
            <div></div>
            <div>
              <a class="tagged-emp">
                Adrian "AyyDee" Cortes
              </a>
              <div>
                <div class="relative employee-rating-badge-sm">
                  <div>
                    <span >5.0</span>
                    <div class="rating-static rating-50"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      \""")
    iex> ReviewsScraper.ReviewsParser.get_employee_review_name(%EmployeeReview{}, review_fragment)
    %EmployeeReview{ rating: 50 }
  """
  def get_employee_review_rate(%EmployeeReview{} = employee_review, employee_review_fragment) do
    rate =
      employee_review_fragment
      |> get_node_class_attribute("div.employee-rating-badge-sm > div > div.rating-static")
      |> get_rating_from_classes()

    Map.put(employee_review, :rating, rate)
  end
end
