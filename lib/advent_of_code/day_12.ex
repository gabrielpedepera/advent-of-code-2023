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
    |> Task.async_stream(fn line ->
      [row, counts] = String.split(line, " ", trim: true, parts: 2)

      sequence =
        row
        |> String.graphemes()
        |> Enum.chunk_by(& &1)
        |> Enum.map(fn chunk ->
          if Enum.any?(chunk, &(&1 == "?")), do: chunk, else: Enum.join(chunk, "")
        end)
        |> List.flatten()

      counts = ~r/\d+/ |> Regex.scan(counts) |> List.flatten() |> Enum.map(&String.to_integer/1)

      {sequence, counts} =
        {(sequence ++ ["?"]) |> List.duplicate(5) |> List.flatten() |> Enum.drop(-1),
         counts |> List.duplicate(5) |> List.flatten()}

      total_arrangements(sequence, counts, 1)
    end)
    |> Enum.reduce(0, fn {:ok, total}, acc -> acc + total end)
  end

  defp total_arrangements(sequence, counts, acc, inside? \\ false)

  defp total_arrangements(
         [sequence_head | sequence_tail] = sequence,
         [count_head | count_tail] = counts,
         acc,
         inside?
       ) do
    case Process.get({sequence, counts}) do
      nil ->
        if length(sequence) < length(counts) do
          memoize({sequence, counts}, 0)
        else
          cond do
            String.contains?(sequence_head, ".") ->
              if inside? do
                memoize({sequence, counts}, 0)
              else
                memoize(
                  {sequence, counts},
                  acc * total_arrangements(sequence_tail, counts, acc, false)
                )
              end

            String.contains?(sequence_head, "#") ->
              cond do
                count_head < String.length(sequence_head) ->
                  memoize({sequence, counts}, 0)

                count_head == String.length(sequence_head) ->
                  memoize(
                    {sequence, counts},
                    if length(sequence_tail) > 0 do
                      acc * total_arrangements(tl(sequence_tail), count_tail, acc)
                    else
                      acc
                    end
                  )

                count_head > String.length(sequence_head) ->
                  memoize(
                    {sequence, counts},
                    if length(sequence_tail) > 0 do
                      acc *
                        total_arrangements(
                          sequence_tail,
                          [count_head - String.length(sequence_head) | count_tail],
                          acc,
                          true
                        )
                    else
                      0
                    end
                  )
              end

            sequence_head == "?" ->
              count_if_filled =
                if length(sequence_tail) > 0 do
                  next_chunk = List.first(sequence_tail)

                  cond do
                    String.contains?(next_chunk, ".") and count_head > 1 ->
                      0

                    String.contains?(next_chunk, "#") and count_head == 1 ->
                      0

                    String.contains?(next_chunk, "?") and count_head == 1 ->
                      total_arrangements(tl(sequence_tail), count_tail, acc, false)

                    count_head == 1 ->
                      if length(sequence_tail) > 0 do
                        total_arrangements(tl(sequence_tail), count_tail, acc, false)
                      else
                        acc
                      end

                    true ->
                      total_arrangements(sequence_tail, [count_head - 1 | count_tail], acc, true)
                  end
                else
                  if count_head == 1 do
                    1
                  else
                    0
                  end
                end

              count_if_skipped =
                if inside? do
                  0
                else
                  total_arrangements(sequence_tail, counts, acc, inside?)
                end

              memoize({sequence, counts}, acc * (count_if_skipped + count_if_filled))
          end
        end

      result ->
        result
    end
  end

  defp total_arrangements([], [], _acc, _inside?), do: 1
  defp total_arrangements([], _counts, _acc, _inside?), do: 0

  defp total_arrangements(sequence, [], _acc, _inside?) do
    if Enum.any?(sequence, &String.contains?(&1, "#")) do
      0
    else
      1
    end
  end

  defp memoize({sequence, counts}, total) do
    Process.put({sequence, counts}, total)
    total
  end

  defp parse_line(line) do
    [regions, groups] = String.split(line, " ")

    regions_list = String.split(regions, "", trim: true)
    groups_list = String.split(groups, ",", trim: true) |> Enum.map(&String.to_integer/1)

    %{regions: regions_list, groups: groups_list, arrangements: 0}
  end

  def count_valid_arrangements(%{regions: regions, groups: groups} = map) do
    valid_arrangements =
      replace_unknowns(regions)
      |> Enum.reduce(0, fn %{arrangement: arrangement, multiplier: multiplier}, acc ->
        if validate_galaxies(arrangement, groups), do: acc + multiplier, else: acc
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
    |> Enum.map(fn arrangement ->
      %{
        arrangement: arrangement,
        multiplier: :math.pow(5, Enum.count(arrangement, &(&1 == "?")))
      }
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
