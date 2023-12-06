defmodule AdventOfCode.Day05 do
  @input AdventOfCode.Input.get!(5, 2023)

  @min_range -1
  @blank_line_pattern ~r{\R\R}
  @digit_pattern ~r{\d+}
  @digit_pair_pattern ~r{(\d+) (\d+)}
  @mapping_pattern ~r{(\d+) (\d+) (\d+)}

  def part1(input \\ @input) do
    [seed_line, transformation_lines] = parse_input_sections(input)

    seeds = parse_individual_seeds(seed_line)
    transformations = parse_transformation_pipelines(transformation_lines)

    transformations
    |> pack_transformation_pipelines(highest_value(seeds, transformations))
    |> find_dependencies(seeds)
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end

  def part2(input \\ @input) do
    [seed_line, transformation_lines] = parse_input_sections(input)

    seeds = parse_seed_ranges(seed_line)
    transformations = parse_transformation_pipelines(transformation_lines)

    transformations
    |> pack_transformation_pipelines(highest_value(seeds, transformations))
    |> find_dependencies(seeds)
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end

  defp parse_input_sections(input) do
    String.split(input, @blank_line_pattern, trim: true, parts: 2)
  end

  defp convert_to_integer_triple([destination, source, length]) do
    {
      String.to_integer(source),
      String.to_integer(destination),
      String.to_integer(length)
    }
  end

  defp convert_to_mapping_entry({destination, source, length}) do
    {source, Range.new(destination, destination + length - 1)}
  end

  defp parse_transformation_pipeline(pipeline) do
    Regex.scan(@mapping_pattern, pipeline, capture: :all_but_first)
    |> Enum.map(&convert_to_integer_triple/1)
    |> Enum.map(&convert_to_mapping_entry/1)
  end

  defp parse_transformation_pipelines(pipeline_lines) do
    String.split(pipeline_lines, @blank_line_pattern, trim: true)
    |> Enum.map(&parse_transformation_pipeline/1)
  end

  defp parse_individual_seeds(seed_line) do
    Regex.scan(@digit_pattern, seed_line)
    |> Enum.map(fn [num] -> String.to_integer(num) end)
    |> Enum.map(fn num -> Range.new(num, num) end)
  end

  defp parse_seed_ranges(seed_line) do
    Regex.scan(@digit_pair_pattern, seed_line, capture: :all_but_first)
    |> Enum.map(fn
      [start, length] ->
        Range.new(
          String.to_integer(start),
          String.to_integer(start) - 1 + String.to_integer(length)
        )
    end)
  end

  defp fill_range_gap([{source, destination_start..destination_end}, {_, source_start.._}])
       when source_start in destination_start..destination_end,
       do: [{source, destination_start..destination_end}]

  defp fill_range_gap([{source, destination_start..destination_end}, {_, source_start.._}]),
    do: [
      {source, destination_start..destination_end//1},
      {destination_end + 1, (destination_end + 1)..(source_start - 1)//1}
    ]

  defp fill_range_gap([_]), do: []

  defp pack_dense_ranges(ranges, upper_limit) do
    ranges
    |> Enum.sort_by(fn {_, destination_start.._} -> destination_start end)
    |> (&Enum.concat([{@min_range, @min_range..@min_range}], &1)).()
    |> (&Enum.concat([&1, [{upper_limit, upper_limit..upper_limit}]])).()
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(&fill_range_gap/1)
  end

  defp pack_transformation_pipelines(pipelines, max) do
    pipelines |> Enum.map(&pack_dense_ranges(&1, max))
  end

  defp clamp_range(from..to, bound_min..bound_max) do
    max(from, bound_min)..min(to, bound_max)
  end

  defp map_input_to_output(input, {source_start, destination_start..destination_end}) do
    clamped_start..clamped_end = clamp_range(input, destination_start..destination_end)

    (clamped_start - destination_start + source_start)..(clamped_end - destination_start +
                                                           source_start)
  end

  defp apply_transformations_to_one_input(transformations, input) do
    transformations
    |> Enum.filter(fn {_, destination} -> not Range.disjoint?(input, destination) end)
    |> Enum.map(&map_input_to_output(input, &1))
  end

  defp apply_transformations(transformations, inputs) do
    inputs |> Enum.flat_map(&apply_transformations_to_one_input(transformations, &1))
  end

  defp find_dependencies(maps, seeds) do
    maps |> Enum.reduce(seeds, &apply_transformations/2)
  end

  defp highest_value(seeds, transformations) do
    max(
      List.flatten(transformations)
      |> Enum.map(fn {source, destination_start..destination_end} ->
        source + (destination_end - destination_start)
      end)
      |> Enum.max(),
      seeds |> Enum.map(&Enum.max/1) |> Enum.max()
    )
  end
end
