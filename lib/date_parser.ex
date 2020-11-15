defmodule ReviewsScraper.DateParser do
  @moduledoc """
  Provides functions for review date parsing
  """

  @months %{
    "January" => 1,
    "February" => 2,
    "March" => 3,
    "April" => 4,
    "May" => 5,
    "June" => 6,
    "July" => 7,
    "August" => 8,
    "September" => 9,
    "October" => 10,
    "November" => 11,
    "December" => 12
  }

  @doc """
    Parse a review date string to elixir Date

    ## Parameters
    - date_string: Review date in format "[Month] [DAY], [YEAR]"

    ## Examples

    iex> ReviewsScraper.DateParser.parse_date("November 14, 2020")
    ~D[2020-11-14]

    iex> ReviewsScraper.DateParser.parse_date("invalid date")
    {:error,  :invalid_date}
  """
  def parse_date(date_string) when is_binary(date_string) do
    date_string
    |> String.trim()
    |> String.replace(",", "")
    |> String.split()
    |> to_date()
  end

  defp to_date([month, day, year]) do
    with month_int <- Map.get(@months, month),
        {day_int, _} <- Integer.parse(day),
        {year_int, _} <- Integer.parse(year) do
      Date.new(year_int, month_int, day_int)
    else
      _ -> {:error, :invalid_date}
    end
  end
end
