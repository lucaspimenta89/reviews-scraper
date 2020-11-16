defmodule ReviewsScraper.DateParserTest do
  use ExUnit.Case

  alias ReviewsScraper.DateParser

  describe "DateParser - Positive tests" do
    test "parse_date/1 - Can parse all months" do
      months = {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      }

      for month <- 1..12 do
        month_name = elem(months, month - 1)

        assert {:ok, parsed_date} = DateParser.parse_date("#{month_name} 01, 2020")

        expected_date = Date.new!(2020, month, 1)

        assert parsed_date == expected_date
      end
    end
  end

  describe "DateParser - Negative tests" do
    test "parse_date/1 - Handle invalid date" do
      assert {:error, _} = DateParser.parse_date("January 32, 2020")
    end

    test "parse_date/1 - Handle invalid match with to_date/1" do
      assert_raise FunctionClauseError, fn ->
        DateParser.parse_date("invalid string")
      end
    end

    test "parse_date/1 - Handle invalid string format" do
      assert {:error, _} = DateParser.parse_date("invalid string format")
    end
  end
end
