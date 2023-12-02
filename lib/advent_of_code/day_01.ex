defmodule AdventOfCode.Day01 do
  @input AdventOfCode.Input.get!(1, 2023)

  @numbers %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def part1(input \\ @input) do
    input
    |> parse()
    |> Enum.map(&get_digits_joined/1)
    |> Enum.sum()
  end

  defp get_digits_joined(string) do
    first_digit = get_digit(string)
    last_digit = get_digit(String.reverse(string))

    (first_digit <> last_digit)
    |> String.to_integer()
  end

  defp get_digit(string) do
    Regex.run(~r/\d/, string) |> List.first()
  end

  def part2(input \\ @input) do
    input
    |> parse()
    |> Enum.map(&get_only_digits/1)
    |> Enum.map(&get_first_and_last_digits_joined/1)
    |> Enum.sum()
  end

  defp parse(input) do
    input |> String.split("\n", trim: true)
  end

  defp get_only_digits(string) do
    Enum.reduce(Map.keys(@numbers), string, fn digit, acc ->
      String.replace(acc, digit, &get_digit_word/1, global: true)
    end)
    |> String.split("")
    |> Enum.filter(fn item ->
      case Integer.parse(item) do
        {_, _} -> true
        _ -> false
      end
    end)
  end

  defp get_digit_word(word) do
    word <> @numbers[word] <> word
  end

  defp get_first_and_last_digits_joined(list) do
    (List.first(list) <> List.last(list))
    |> String.to_integer()
  end
end
