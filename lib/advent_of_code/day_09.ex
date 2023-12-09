defmodule AdventOfCode.Day09 do
  @input AdventOfCode.Input.get!(9, 2023)

  def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.map(&1, fn element -> String.to_integer(element) end))
    |> Enum.map(&Sequence.extrapolate/1)
    |> Enum.map(&Sequence.add_elements_at_end/1)
    |> Enum.reduce(0, fn list, acc ->
      acc + Sequence.get_extrapolated_number(list)
    end)
  end

  def part2(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.map(&1, fn element -> String.to_integer(element) end))
    |> Enum.map(&Sequence.extrapolate/1)
    |> Enum.map(&Sequence.add_elements_at_beginning/1)
    |> Enum.reduce(0, fn list, acc ->
      [first | _] = list
      acc + hd(first)
    end)
  end
end

defmodule Sequence do
  def extrapolate(seq, acc \\ []) do
    diff_seq = diff(seq)

    if Enum.all?(diff_seq, fn x -> x == 0 end) do
      Enum.concat(acc, [seq, diff_seq])
    else
      case diff_seq do
        [val] ->
          last_val = List.last(seq)
          Enum.concat(acc, [Enum.concat(seq, [last_val + val])])

        next_seq ->
          extrapolate(next_seq, Enum.concat(acc, [seq]))
      end
    end
  end

  def add_elements_at_end(seq) do
    List.foldr(seq, [], fn x, acc ->
      case acc do
        [] -> [Enum.concat(x, [0])]
        _ -> [Enum.concat(x, [List.last(x) + List.last(List.first(acc))]) | acc]
      end
    end)
  end

  def add_elements_at_beginning(seq) do
    List.foldr(seq, [], fn x, acc ->
      case acc do
        [] -> [Enum.concat([0], x)]
        _ -> [Enum.concat([List.first(x) - List.first(List.first(acc))], x) | acc]
      end
    end)
  end

  defp diff(seq) do
    Enum.zip(seq, Enum.drop(seq, 1))
    |> Enum.map(fn {a, b} -> b - a end)
  end

  def get_extrapolated_number(list) do
    [head | _] = list

    head
    |> Enum.reverse()
    |> hd()
  end

  def get_first_extrapolated_number(list) do
    [head | _] = list

    head
    |> hd()
  end
end
