# ReviewsScraper - Challenge

# Methodology

The challenge consists of fetching the first five pages of reviews about the McKaig Chevrolet Buick - A Dealer For The People at https://www.dealerrater.com.

With the reviews in hand, the application must decide the top three overly rated reviews and print it on the console.

The application is implemented using [Elixir](https://elixir-lang.org/) as the programming language, [ExUnit](https://hexdocs.pm/ex_unit/ExUnit.html) for testing, [HTTPoison](https://hexdocs.pm/httpoison/HTTPoison.html) for HTTP requests, [Poison](https://hexdocs.pm/poison/api-reference.html) for JSON encoding, and [Floki](https://hexdocs.pm/floki/Floki.html) for HTML parsing.

## Data fetching and processing

In order to fetch the HTML pages with the reviews and extract the information, HTTPoison was used to perform HTTP requests to retrieve the HTML of the targeted pages, it happens on the `ReviewsScraper.Scraper.get_reviews/0` function. 

For each page retrieval, the HTML is parsed into lists of `%ReviewsScraper.Models.Review{}` structs. All this processing is done using `Task.async_stream/3` which means that the requests and the HTML parsing are made concurrently witch makes the application display the result quickly.

## Selecting the top three "overly positive" reviews

For each review a score is calculated based on the number of stars given in the review then the application will sort the reviews based on the score and the date of the review. The top three "overly positive" reviews are the ones with the biggest scores that were recently added to the website.

## Review score calculation

When analyzing the HTML of each review, the following attributes can be found:

1. Overall rating
2. Individual rating for each service provided
3. Involved employee rating
4. If the review author recommends the services for other users

From items 1 to 3 the attributes are displayed using stars that are controlled by the CSS class `rating-*`. This CSS class provides values from `rating-00` to `rating-50`. For item 4 the value is `Yes` or `No`.

In order to calculate the score of a review, all attributes are converted into numbers. 

For the overall rating, individual service rating, and employee ratings the numeric part is extracted from the  `rating-*` CSS class and parsed to an integer value. Then the values that can be from 0 to 50 are added to the score. 

If the review recommends the services for another user, another `50` points are added to the score. 

This method will provide high scores for the reviews that have more stars and more employees involved.

# Output

The output of the application is a JSON representation of the most overly rated reviews. The JSON format was chosen because it is an easy format to read and also can easily be consumed by another application.

An example of the output:

```json
[
  {
    "score": 650,
    "rating": 50,
    "individual_rates": [
      {
        "rating": 50,
        "name": "Customer Service"
      },
      {
        "rating": 50,
        "name": "Quality of Work"
      },
      {
        "rating": 50,
        "name": "Friendliness"
      },
      {
        "rating": 50,
        "name": "Pricing"
      },
      {
        "rating": 50,
        "name": "Overall Experience"
      },
      {
        "rating": "yes",
        "name": "Recommend Dealer"
      }
    ],
    "employees_reviews": [
      {
        "rating": 50,
        "name": "Adrian \"AyyDee\" Cortes"
      },
      {
        "rating": 50,
        "name": "Freddie Tomlinson"
      },
      {
        "rating": 50,
        "name": "Patrick Evans"
      },
      {
        "rating": 50,
        "name": "Mariela Hernandez"
      },
      {
        "rating": 50,
        "name": "Brandon McCloskey"
      },
      {
        "rating": 50,
        "name": "Summur Villareal"
      }
    ],
    "date": "2020-10-15",
    "content": "I was in a very tight bind being over my head in my car loan. Adrian came through like a knight in shining armor!!!\r\nI even came back to get my wife a vehicle!",
    "author": "gr81allday"
  },
  {
    "score": 650,
    "rating": 50,
    "individual_rates": [
      {
        "rating": 50,
        "name": "Customer Service"
      },
      {
        "rating": 50,
        "name": "Quality of Work"
      },
      {
        "rating": 50,
        "name": "Friendliness"
      },
      {
        "rating": 50,
        "name": "Pricing"
      },
      {
        "rating": 50,
        "name": "Overall Experience"
      },
      {
        "rating": "yes",
        "name": "Recommend Dealer"
      }
    ],
    "employees_reviews": [
      {
        "rating": 50,
        "name": "Jeriamy Schumacher"
      },
      {
        "rating": 50,
        "name": "Dennis Smith"
      },
      {
        "rating": 50,
        "name": "Freddie Tomlinson"
      },
      {
        "rating": 50,
        "name": "Mariela Hernandez"
      },
      {
        "rating": 50,
        "name": "Faye Hinds"
      },
      {
        "rating": 50,
        "name": "Brandon McCloskey"
      }
    ],
    "date": "2020-09-18",
    "content": "Love the mckaig in gladewater tx they had exactly what we was looking for and  gave us a great deal better than any other dealership we been to and we researched around to find the best deal for a month and nobody could under price them great people very nice and will take care of you great if anybody is looking to get a new or even a used car I wouldn't waste my time any where else !!!",
    "author": "Marvin4208"
  },
  {
    "score": 550,
    "rating": 50,
    "individual_rates": [
      {
        "rating": 50,
        "name": "Customer Service"
      },
      {
        "rating": 50,
        "name": "Quality of Work"
      },
      {
        "rating": 50,
        "name": "Friendliness"
      },
      {
        "rating": 50,
        "name": "Pricing"
      },
      {
        "rating": 50,
        "name": "Overall Experience"
      },
      {
        "rating": "yes",
        "name": "Recommend Dealer"
      }
    ],
    "employees_reviews": [
      {
        "rating": 50,
        "name": "Patrick Evans"
      },
      {
        "rating": 50,
        "name": "Mariela Hernandez"
      },
      {
        "rating": 50,
        "name": "Faye Hinds"
      },
      {
        "rating": 50,
        "name": "Chris Williams"
      }
    ],
    "date": "2020-09-29",
    "content": "Patrick is the best there is! He will take care of all of your needs, and quickly! He is such a joy to deal with! Sorry, but I am his favorite customer, so you will have to be his second or third! LOL",
    "author": "Monica1815.mh"
  }
]
```

# Tests
Requires [Elixir installation](https://elixir-lang.org/install.html)

To  execute tests run the following command

```
$ mix deps.get
$ mix test
```

Current tests coverage, obtained by running `$ mix test --cover`

```
Percentage | Module
-----------|--------------------------
   100.00% | ReviewsScraper.CLI
   100.00% | ReviewsScraper.DateParser
   100.00% | ReviewsScraper.HtmlParser
   100.00% | ReviewsScraper.Models.EmployeeReview
   100.00% | ReviewsScraper.Models.IndividualReview
   100.00% | ReviewsScraper.Models.Review
   100.00% | ReviewsScraper.ReviewsParser
   100.00% | ReviewsScraper.ReviewsPrinter
   100.00% | ReviewsScraper.ReviewsScore
   100.00% | ReviewsScraper.Scraper
   100.00% | ReviewsScraper.TestCase
   100.00% | ReviewsScraper.TestsSetups
-----------|--------------------------
   100.00% | Total
```


# How to run the application

Clone the repository:

```
$ git clone https://github.com/lucaspimenta89/reviews-scraper.git
$ cd reviews-scraper
```

## Running locally
Requires [Elixir installation](https://elixir-lang.org/install.html)

```
$ mix local.hex && mix local.rebar
$ mix do deps.get, escript.build
$ ./reviews_scraper
```

## Using Docker

Requires [Docker installation](https://docs.docker.com/get-docker/)

```
$ docker build --tag reviews-scraper:1.0 .
$ docker run --name reviews-scrapper reviews-scraper:1.0
```

To remove the container image

```
$ docker rm --force /reviews-scrapper
```

## Using docker-compose

Requires [Docker Compose installation](https://docs.docker.com/compose/install/)

```bash
$ docker-compose up reviews_scraper
```

# Documentation

Execute the following command:

```
$ mix deps.get
$ mix docs
```

The documentation will be available at the `doc` folder where you can open the `index.html` page in your browser