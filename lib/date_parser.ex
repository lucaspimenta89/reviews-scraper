defmodule ReviewsScraper.DateParser do

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

  def parse_date!(date_string) when is_binary(date_string) do
    date_string
    |> String.trim()
    |> String.replace(",", "")
    |> String.split()
    |> to_date!()
  end

  defp to_date!([month, day, year]) do
    with month_int = Map.get(@months, month),
        {day_int, _} = Integer.parse(day),
        {year_int, _} = Integer.parse(year),
        {:ok, date } = Date.new(year_int, month_int, day_int) do
      date
    end
  end
end
