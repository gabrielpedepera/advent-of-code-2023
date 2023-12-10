defmodule AdventOfCode.Day10 do
  @input AdventOfCode.Input.get!(10, 2023)
  def part1(input \\ @input) do
    Pipes.solve(input, :part1)
  end

  def part2(input \\ @input) do
    Pipes.solve(input, :part2)
  end
end

defmodule Pipes do
  @directions ["L", "D", "R", "U"]
  @pipe_symbols %{
    "-" => ["L", "R"],
    "|" => ["D", "U"],
    "F" => ["R", "D"],
    "7" => ["L", "D"],
    "J" => ["L", "U"],
    "L" => ["R", "U"]
  }

  def solve(input, :part1) do
    map = parse(input)
    start_position = find_start_position(map)
    starting_coordinates = find_starting_coordinates(map, start_position)
    loop_length = calculate_loop_length(map, starting_coordinates, start_position)
    div(loop_length, 2)
  end

  def solve(input, :part2) do
    map = parse(input)
    {start, _} = find_start(map)
    {loop_tiles, _} = find_loop(start, map)
    {{max_x, max_y}, {roomy_max_x, roomy_max_y}} = get_max_values(map)
    border = define_border(roomy_max_x, roomy_max_y)
    roomy_loop = roomy_loop(loop_tiles, map)

    n_outside =
      count_outside_tiles(border, [], roomy_loop, roomy_max_x, roomy_max_y, MapSet.new())

    (max_x + 1) * (max_y + 1) - n_outside - MapSet.size(loop_tiles)
  end

  defp find_start(map) do
    Enum.find(map, fn {_, tile} -> tile == "S" end)
  end

  defp get_max_values(map) do
    {max_x, _} = Map.keys(map) |> Enum.max_by(fn {x, _} -> x end)
    {_, max_y} = Map.keys(map) |> Enum.max_by(fn {_, y} -> y end)
    roomy_max_x = max_x * 2
    roomy_max_y = max_y * 2

    {{max_x, max_y}, {roomy_max_x, roomy_max_y}}
  end

  defp define_border(roomy_max_x, roomy_max_y) do
    bx1 = for x <- -1..(roomy_max_x + 1), do: {x, -1}
    bx2 = for x <- -1..(roomy_max_x + 1), do: {x, roomy_max_y + 1}
    by1 = for y <- -1..(roomy_max_y + 1), do: {-1, y}
    by2 = for y <- -1..(roomy_max_y + 1), do: {roomy_max_x + 1, y}
    MapSet.new(bx1 ++ bx2 ++ by1 ++ by2) |> Enum.to_list()
  end

  defp roomy_loop(loop_tiles, map) do
    loop_tiles
    |> Enum.map(fn {x, y} -> {x * 2, y * 2} end)
    |> MapSet.new()
    |> then(fn tiles ->
      Enum.reduce(tiles, tiles, fn {x, y}, acc ->
        {div(x, 2), div(y, 2)}
        |> find_connections({x, y}, map)
        |> MapSet.new()
        |> MapSet.union(acc)
      end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, x}, line_acc ->
        Map.put(line_acc, {x, y}, c)
      end)
    end)
  end

  defp find_start_position(map) do
    Enum.find(map, fn {{_, _}, c} -> c == "S" end)
    |> elem(0)
  end

  defp find_starting_coordinates(map, {start_x, start_y}) do
    Enum.reduce_while(@directions, nil, fn direction, _acc ->
      case direction do
        "L" -> check_direction(map, start_x - 1, start_y, ["-", "L", "F"])
        "D" -> check_direction(map, start_x, start_y + 1, ["|", "L", "J"])
        "R" -> check_direction(map, start_x + 1, start_y, ["-", "J", "7"])
        "U" -> check_direction(map, start_x, start_y - 1, ["|", "F", "7"])
      end
    end)
  end

  defp check_direction(map, x, y, symbols) do
    symbol = Map.get(map, {x, y})
    if symbol in symbols, do: {:halt, {x, y}}, else: {:cont, nil}
  end

  defp calculate_loop_length(map, starting_coordinates, start_position) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(
      %{
        length: 1,
        prev_coordinates: start_position,
        current_coordinates: starting_coordinates
      },
      fn _,
         %{
           length: length,
           prev_coordinates: {prev_x, prev_y},
           current_coordinates: {curr_x, curr_y}
         } ->
        symbol = Map.get(map, {curr_x, curr_y})
        {next_x, next_y} = find_next_coordinates(symbol, {prev_x, prev_y}, {curr_x, curr_y})

        if Map.get(map, {next_x, next_y}) == "S" do
          {:halt, length + 1}
        else
          {:cont,
           %{
             prev_coordinates: {curr_x, curr_y},
             current_coordinates: {next_x, next_y},
             length: length + 1
           }}
        end
      end
    )
  end

  defp find_next_coordinates(symbol, {prev_x, prev_y}, {curr_x, curr_y}) do
    possible_directions = @pipe_symbols[symbol]

    Enum.find_value(possible_directions, fn direction ->
      next_coordinates = move_in_direction(direction, {curr_x, curr_y})
      if next_coordinates != {prev_x, prev_y}, do: next_coordinates
    end)
  end

  defp move_in_direction("L", {x, y}), do: {x - 1, y}
  defp move_in_direction("D", {x, y}), do: {x, y + 1}
  defp move_in_direction("R", {x, y}), do: {x + 1, y}
  defp move_in_direction("U", {x, y}), do: {x, y - 1}

  defp find_loop({sx, sy}, map) do
    next =
      [
        if(map[{sx, sy - 1}] in ~w[| 7 F], do: {sx, sy - 1}, else: nil),
        if(map[{sx, sy + 1}] in ~w[| J L], do: {sx, sy + 1}, else: nil),
        if(map[{sx - 1, sy}] in ~w[- L F], do: {sx - 1, sy}, else: nil),
        if(map[{sx + 1, sy}] in ~w[- 7 J], do: {sx + 1, sy}, else: nil)
      ]
      |> Enum.reject(&is_nil/1)

    loop([], next, MapSet.new([{sx, sy}]), 0, map)
  end

  defp loop([], [], been, steps, _map), do: {been, steps}
  defp loop([], next, been, steps, map), do: loop(next, [], been, steps + 1, map)

  defp loop([tile | rest], next, been, steps, map) do
    new_next = Enum.reject(find_connections(tile, map), &MapSet.member?(been, &1)) ++ next
    loop(rest, new_next, MapSet.put(been, tile), steps, map)
  end

  defp find_connections(tile, map), do: find_connections(tile, tile, map)

  defp find_connections(tile, {x, y}, map) do
    case map[tile] do
      "-" -> [{x - 1, y}, {x + 1, y}]
      "|" -> [{x, y - 1}, {x, y + 1}]
      "J" -> [{x, y - 1}, {x - 1, y}]
      "L" -> [{x, y - 1}, {x + 1, y}]
      "7" -> [{x, y + 1}, {x - 1, y}]
      "F" -> [{x, y + 1}, {x + 1, y}]
      "S" -> []
    end
  end

  defp count_outside_tiles([], [], _, _, _, outsides) do
    outsides
    |> Enum.filter(fn {x, y} -> rem(x, 2) == 0 and rem(y, 2) == 0 end)
    |> Enum.count()
  end

  defp count_outside_tiles([], next, forbidden, max_x, max_y, outsides),
    do: count_outside_tiles(next, [], forbidden, max_x, max_y, outsides)

  defp count_outside_tiles([tile | rest], next, forbidden, max_x, max_y, outsides) do
    news = outside_adjs(tile, forbidden, max_x, max_y)
    new_forbidden = MapSet.new(news) |> MapSet.union(forbidden)
    new_outsides = MapSet.new(news) |> MapSet.union(outsides)
    count_outside_tiles(rest, news ++ next, new_forbidden, max_x, max_y, new_outsides)
  end

  defp outside_adjs({x, y}, forbidden, max_x, max_y) do
    for {a, b} <- [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}],
        a >= 0,
        a <= max_x,
        b >= 0,
        b <= max_y do
      {a, b}
    end
    |> Enum.reject(&MapSet.member?(forbidden, &1))
  end
end
