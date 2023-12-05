defmodule AdventOfCode.Day04 do
  @input AdventOfCode.Input.get!(4, 2023)
  def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Card.from_line/1)
    |> Enum.reject(&(&1 == nil))
    |> Enum.map(&Card.calculate_points/1)
    |> Enum.sum()
  end

  def part2(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Card.from_line/1)
    |> Enum.reject(&(&1 == nil))
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {card, index}, acc ->
      index = index + 1

      number_won =
        card.numbers |> Enum.filter(&Enum.member?(card.winning_numbers, &1)) |> Enum.count()

      acc
      |> update_counter_map(index, number_won, Map.get(acc, index, 1))
      |> Map.update(index, 1, & &1)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp update_counter_map(acc, _index, numbers_won, _multiplier) when numbers_won <= 0 do
    acc
  end

  defp update_counter_map(acc, index, numbers_won, multiplier) do
    0..(numbers_won - 1)
    |> Enum.reduce(acc, fn num_index, acc ->
      Map.update(acc, index + num_index + 1, multiplier + 1, &(&1 + multiplier))
    end)
  end
end

defmodule Card do
  defstruct id: nil, winning_numbers: [], numbers: [], numbers_matched: []

  def from_line(line) do
    ~r/Card\s+(?<id>\d+):\s+(?<winning_numbers_string>.+)\s+\|\s+(?<numbers_line>.+)/
    |> Regex.named_captures(line)
    |> from_map()
  end

  def calculate_points(card) do
    Enum.reduce(card.numbers_matched, 0, fn _, acc -> if acc == 0, do: 1, else: acc * 2 end)
  end

  defp from_map(map) when is_map(map) do
    %{
      "id" => id,
      "winning_numbers_string" => winning_numbers_string,
      "numbers_line" => numbers_line
    } = map

    winning_numbers = string_to_number_list(winning_numbers_string)
    numbers = string_to_number_list(numbers_line)

    %Card{
      id: String.to_integer(id),
      winning_numbers: winning_numbers,
      numbers: numbers,
      numbers_matched: Enum.filter(numbers, &Enum.member?(winning_numbers, &1))
    }
  end

  defp from_map(_), do: nil

  defp string_to_number_list(string) do
    string
    |> String.split(~r/\s+/)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.to_integer/1)
    |> Enum.sort()
  end
end
