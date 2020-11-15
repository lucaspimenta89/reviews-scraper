defmodule ReviewsScraper.TestsSetups do

  alias ReviewsScraper.Models.{Review, IndividualReview, EmployeeReview}

  @review_html """
    <div class="review-entry">
      <a name="r7565083"></a>
      <div class="review-date">
        <div>November 14, 2020</div>
        <div class="dealership-rating">
          <div class="rating-static rating-50"></div>
          <div class="rating-static hidden-xs rating-50"></div>
          <div>SALES VISIT - NEW</div>
        </div>
      </div>
      <div class="review-wrapper">
        <div>
          <h3>"I came here for the friendly but low pressure service...."</h3>
          <span>- lisapantlin</span>
        </div>

        <div>
          <div>
            <p class="review-content">
              [REVIEW CONTENTE]
            </p>
            <a id="7565083">Read More</a>
          </div>
        </div>

        <div class="review-ratings-all">
          <div class="table">
            <div class="tr">
              <div>Customer Service</div>
              <div class="rating-static-indv rating-50"></div>
            </div>
            <div class="tr">
              <div>Quality of Work</div>
              <div class="rating-static-indv rating-00"></div>
            </div>
            <div class="tr margin-bottom-md">
              <div>Friendliness</div>
              <div class="rating-static-indv rating-50"></div>
            </div>
            <div class="tr margin-bottom-md">
              <div>Pricing</div>
              <div class="rating-static-indv rating-50"></div>
            </div>
            <div class="tr margin-bottom-md">
              <div>Overall Experience</div>
              <div class="rating-static-indv rating-50"></div>
            </div>
            <div class="tr">
              <div>Recommend Dealer</div>
              <div>Yes</div>
            </div>
          </div>
        </div>
        <div>
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
              <div class="review-employee">
                <div class="table">
                  <div></div>
                  <div>
                    <a class="tagged-emp">
                      Brandon McCloskey
                    </a>
                    <div>
                      <div class="employee-rating-badge-sm">
                        <div>
                          <span>5.0</span>
                          <div class="rating-static rating-50"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="review-employee">
                <div class="table">
                  <div></div>
                  <div>
                    <a class="tagged-emp">
                      Alisa Cerney
                    </a>
                    <div>
                      <div class="employee-rating-badge-sm">
                        <div>
                          <span>5.0</span>
                          <div class="rating-static rating-50"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="review-employee">
                <div class="table">
                  <div></div>
                  <div>
                    <a class="tagged-emp">
                      Summur Villareal
                    </a>
                    <div>
                      <div class="employee-rating-badge-sm">
                        <div>
                          <span>5.0</span>
                          <div class="rating-static rating-50"></div>
                        </div>
                      </div>
                    </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  """

  def setup_reviews_html(setup) do
    reviews_html = """
      <html class="no-js">
        <head></head>
        <body>
          <div>
            #{@review_html}
          </div>
        </body>
      </html>
    """
    {:ok, Map.put(setup, :reviews_html, reviews_html)}
  end

  def setup_review_html_tree(setup) do
    {:ok, parsed_fragment} = Floki.parse_fragment(@review_html)

    {:ok, Map.put(setup, :review_html_tree, parsed_fragment)}
  end

  def setup_review(setup) do
    review = %Review{
      rating: 50,
      date: ~D[2020-11-14],
      author: "lisapantlin",
      content: "[REVIEW CONTENTE]",
      individual_rates: [
        %IndividualReview{ name: "Customer Service", rating: 50 },
        %IndividualReview{ name: "Quality of Work", rating: 0 },
        %IndividualReview{ name: "Friendliness", rating: 50 },
        %IndividualReview{ name: "Pricing", rating: 50 },
        %IndividualReview{ name: "Overall Experience", rating: 50 },
        %IndividualReview{ name: "Recommend Dealer", rating: "yes" }
      ],
      employees_reviews: [
        %EmployeeReview{ name: "Adrian \"AyyDee\" Cortes", rating: 50},
        %EmployeeReview{ name: "Brandon McCloskey", rating: 50},
        %EmployeeReview{ name: "Alisa Cerney", rating: 50},
        %EmployeeReview{ name: "Summur Villareal", rating: 50}
      ],
      score: 500
    }
    {:ok, Map.put(setup, :review, review)}
  end

end
