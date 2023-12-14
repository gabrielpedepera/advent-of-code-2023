defmodule AdventOfCode.Day12 do
  @input AdventOfCode.Input.get!(12, 2023)
  def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&count_valid_arrangements/1)
    |> Enum.reduce(0, fn el, acc ->
      acc + el[:arrangements]
    end)
  end

  def part2(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&unfold_records/1)
    |> Enum.map(&count_valid_arrangements/1)
    |> Enum.reduce(0, fn el, acc ->
      acc + el[:arrangements]
    end)
  end

  defp unfold_records(%{regions: regions, groups: groups} = map) do
    unfolded_regions = unfold_regions(regions)
    unfolded_groups = unfold_groups(groups)
    %{map | regions: unfolded_regions, groups: unfolded_groups}
  end

  defp unfold_regions(regions) do
    regions
    |> List.duplicate(5)
    |> Enum.intersperse("?")
    |> List.flatten()
  end

  defp unfold_groups(groups) do
    groups
    |> List.duplicate(5)
    |> List.flatten()
  end

  defp parse_line(line) do
    [regions, groups] = String.split(line, " ")

    regions_list = String.split(regions, "", trim: true)
    groups_list = String.split(groups, ",", trim: true) |> Enum.map(&String.to_integer/1)

    %{regions: regions_list, groups: groups_list, arrangements: 0}
  end

  defp count_valid_arrangements(%{regions: regions, groups: groups} = map) do
    valid_arrangements =
      replace_unknowns(regions)
      |> Enum.reduce(0, fn new_regions, acc ->
        if validate_galaxies(new_regions, groups), do: acc + 1, else: acc
      end)

    %{map | arrangements: valid_arrangements}
  end

  defp replace_unknowns(regions) do
    unknown_count = Enum.count(regions, &(&1 == "?"))

    Stream.map(0..(round(:math.pow(2, unknown_count)) - 1), fn n ->
      binary = Integer.to_string(n, 2) |> String.pad_leading(unknown_count, "0")

      replacements =
        Enum.map(String.split(binary, "", trim: true), fn
          "0" -> "."
          "1" -> "#"
        end)

      replace_unknowns_in_regions(regions, replacements)
    end)
  end

  defp replace_unknowns_in_regions(regions, replacements) do
    {result, _} =
      Enum.map_reduce(regions, replacements, fn
        "?", [replacement | rest_replacements] -> {replacement, rest_replacements}
        region, replacements -> {region, replacements}
      end)

    result
  end

  def validate_galaxies(spring, groups) do
    galaxy_counts = count_galaxies(spring, [])

    galaxy_counts_and_groups_match?(galaxy_counts, groups)
  end

  defp galaxy_counts_and_groups_match?(galaxy_counts, groups) do
    galaxy_counts
    |> Enum.filter(&(&1 != 0))
    |> Kernel.==(groups)
  end

  defp count_galaxies([], counts), do: Enum.reverse(counts)
  defp count_galaxies(["#" | rest], []), do: count_galaxies(rest, [1])
  defp count_galaxies(["#" | rest], [h | t]), do: count_galaxies(rest, [h + 1 | t])
  defp count_galaxies(["." | rest], counts), do: count_galaxies(rest, [0 | counts])
  defp count_galaxies(_, counts), do: counts
end
