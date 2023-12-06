defmodule AdventOfCode.Day06 do
  @input AdventOfCode.Input.get!(6, 2023)

  def part1(input \\ @input) do
    input
    |> to_tuples()
    |> Enum.map(&add_distances/1)
    |> Enum.map(&count_winning_ways/1)
    |> Enum.reduce(1, fn counter, acc -> counter * acc end)
  end

  def part2(input \\ @input) do
    input
    |> to_single_tuple()
    |> add_distances()
    |> count_winning_ways()
  end

  defp to_tuples(input) do
    [time_line, distance_line | _] = String.split(input, "\n")
    times = get_numbers(time_line)
    distances = get_numbers(distance_line)
    Enum.zip(times, distances)
  end

  defp get_numbers(line) do
    line
    |> String.split()
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
  end

  defp add_distances({time, distance}) do
    distances =
      for hold_time <- 0..time do
        travel_time = time - hold_time
        travel_distance = hold_time * travel_time
        {hold_time, travel_distance}
      end

    {time, distance, distances}
  end

  defp count_winning_ways({_time, distance, distances}) do
    Enum.filter(distances, fn {_hold_time, travel_distance} -> travel_distance > distance end)
    |> length()
  end

  def to_single_tuple(input) do
    [time_line, distance_line | _] = String.split(input, "\n")
    time = get_single_number(time_line)
    distance = get_single_number(distance_line)
    {time, distance}
  end

  defp get_single_number(line) do
    line
    |> String.split()
    |> Enum.drop(1)
    |> Enum.join("")
    |> String.to_integer()
  end
end
