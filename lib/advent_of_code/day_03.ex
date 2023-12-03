defmodule AdventOfCode.Day03 do
  @input AdventOfCode.Input.get!(3, 2023)
  def part1(input \\ @input) do
    schematic =
      input
      |> String.split("\n", trim: true)

    schematic
    |> Enum.with_index()
    |> Enum.map(&get_numbers_and_indices/1)
    |> List.flatten()
    |> Enum.map(fn tuple -> Tuple.append(tuple, get_adjacent_points(tuple)) end)
    |> Enum.filter(fn {_, _, _, points} ->
      validate_point(schematic, points)
    end)
    |> Enum.map(fn {number, _, _, _} -> number end)
    |> Enum.sum()
  end

  def get_numbers_and_indices({line, line_index}) do
    line
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.reduce({[], ""}, fn {char, char_index}, {acc, current_number} ->
      cond do
        String.match?(char, ~r/\d/) ->
          {acc, current_number <> char}

        current_number != "" ->
          {[
             {String.to_integer(current_number),
              (char_index - String.length(current_number))..(char_index - 1), line_index}
             | acc
           ], ""}

        true ->
          {acc, ""}
      end
    end)
    |> case do
      {acc, ""} ->
        acc

      {acc, current_number} ->
        [
          {String.to_integer(current_number),
           (String.length(line) - String.length(current_number))..(String.length(line) - 1),
           line_index}
          | acc
        ]
    end
    |> Enum.reverse()
  end

  def get_adjacent_points({_, x_range, y}) do
    x_start = Enum.min(x_range) - 1
    x_end = Enum.max(x_range) + 1
    y_start = y - 1
    y_end = y + 1

    for x <- x_start..x_end, y <- y_start..y_end, do: {x, y}
  end

  def point_has_symbol?(schematic, {x, y}) do
    line = Enum.at(schematic, y)

    if line do
      char = String.at(line, x)
      char not in [nil, "."] and not String.match?(char, ~r/\d/)
    else
      false
    end
  end

  def validate_point(schematic, points) do
    Enum.any?(points, &point_has_symbol?(schematic, &1))
  end

  def validate_all_points(schematic, points_list) do
    schematic = String.split(schematic, "\n", trim: true)
    Enum.map(points_list, &validate_point(schematic, &1))
  end

  def part2(input \\ @input) do
    schematic =
      input
      |> String.split("\n", trim: true)

    numbers =
      schematic
      |> Enum.with_index()
      |> Enum.map(&get_numbers_and_indices/1)
      |> List.flatten()
      |> Enum.map(fn tuple -> Tuple.append(tuple, get_adjacent_points(tuple)) end)

    get_star_numbers(schematic, numbers)
    |> Enum.map(fn [x, y] -> x * y end)
    |> Enum.sum()
  end

  def get_star_positions(schematic) do
    Enum.with_index(schematic)
    |> Enum.flat_map(fn {row, y} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.filter(fn {cell, _} -> cell == "*" end)
      |> Enum.map(fn {_, x} -> {y, x} end)
    end)
  end

  def get_numbers_for_star(numbers, {star_y, star_x}) do
    numbers
    |> Enum.filter(fn {_, _, _, points} ->
      Enum.any?(points, fn {x, y} -> x == star_x and y == star_y end)
    end)
    |> Enum.map(fn {number, _, _, _} -> number end)
  end

  def get_star_numbers(schematic, numbers) do
    get_star_positions(schematic)
    |> Enum.map(&get_numbers_for_star(numbers, &1))
    |> Enum.filter(&match?([_, _], &1))
  end
end
