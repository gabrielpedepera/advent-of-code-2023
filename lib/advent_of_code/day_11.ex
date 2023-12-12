defmodule AdventOfCode.Day11 do
  @input AdventOfCode.Input.get!(11, 2023)
  def part1(input \\ @input) do
    input
    |> CosmicExpansion.expand(2)
    |> CosmicExpansion.assign_numbers()
    |> CosmicExpansion.calculate_distances()
    |> Map.values()
    |> Enum.sum()
  end

  def part2(factor \\ 1_000_000, input \\ @input) do
    input
    |> CosmicExpansion.expand(factor)
    |> CosmicExpansion.assign_numbers()
    |> CosmicExpansion.calculate_distances()
    |> Map.values()
    |> Enum.sum()
  end
end

defmodule CosmicExpansion do
  def expand(input, factor) do
    lines = String.split(input, "\n")
    matrix = Enum.map(lines, &String.graphemes/1)

    empty_rows =
      Enum.filter(0..(length(matrix) - 1), fn row_index ->
        Enum.all?(Enum.at(matrix, row_index), &(&1 != "#"))
      end)

    empty_cols =
      Enum.filter(0..(length(Enum.at(matrix, 0)) - 1), fn col_index ->
        Enum.all?(matrix, &(&1 |> Enum.at(col_index) != "#"))
      end)

    Enum.reduce(0..(length(matrix) - 1), %{}, fn row_index, map ->
      Enum.reduce(0..(length(Enum.at(matrix, row_index)) - 1), map, fn col_index, map ->
        val = Enum.at(Enum.at(matrix, row_index), col_index) || "."

        if val == "#" do
          x_offset = col_index + (factor - 1) * Enum.count(empty_cols, &(&1 < col_index))
          y_offset = row_index + (factor - 1) * Enum.count(empty_rows, &(&1 < row_index))
          Map.put(map, {y_offset, x_offset}, val)
        else
          map
        end
      end)
    end)
  end

  def assign_numbers(universe_map) do
    sorted_universe =
      Enum.sort(universe_map, fn {coords1, _}, {coords2, _} -> coords1 < coords2 end)

    {numbered_universe, _} =
      Enum.reduce(sorted_universe, {%{}, 1}, fn {coords, val}, {acc, num} ->
        if val == "#" do
          {Map.put(acc, coords, Integer.to_string(num)), num + 1}
        else
          {Map.put(acc, coords, val), num}
        end
      end)

    numbered_universe
  end

  def calculate_distances(galaxies) when is_list(galaxies) do
    galaxy_pairs = for g1 <- galaxies, g2 <- galaxies, g1 < g2, do: {g1, g2}

    galaxy_pairs
    |> Enum.map(fn {{x1, y1}, {x2, y2}} -> abs(x1 - x2) + abs(y1 - y2) end)
    |> Enum.sum()
  end

  def calculate_distances(universe_map) when is_map(universe_map) do
    galaxies =
      Enum.filter(universe_map, fn {_, val} -> val != "." end)
      |> Enum.map(fn {{x, y}, val} -> {{x, y}, String.to_integer(val)} end)

    Enum.reduce(galaxies, %{}, fn {coords1, g1}, acc ->
      Enum.reduce(galaxies, acc, fn {coords2, g2}, acc ->
        if g1 < g2 do
          Map.put(acc, {g1, g2}, manhattan_distance(coords1, coords2))
        else
          acc
        end
      end)
    end)
  end

  def manhattan_distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end
