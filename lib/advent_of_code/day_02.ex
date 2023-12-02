defmodule AdventOfCode.Day02 do
  @input AdventOfCode.Input.get!(2, 2023)

  def part1(input \\ @input) do
    games =
      input
      |> parse()
      |> Enum.map(&ElfGame.parse_game(&1))

    possible_games = ElfGame.possible_games(games, Cube.new(12, 13, 14))

    ElfGame.sum_ids(possible_games)
  end

  def part2(_args) do
  end

  defp parse(input) do
    input |> String.split("\n", trim: true)
  end
end

defmodule Game do
  defstruct id: 0, rounds: []

  def new(id), do: %Game{id: id, rounds: []}

  def add_round(game, round), do: %{game | rounds: [round | game.rounds]}
end

defmodule Cube do
  defstruct red: 0, green: 0, blue: 0

  def new(red, green, blue), do: %Cube{red: red, green: green, blue: blue}

  def possible?(cube, bag) do
    cube.red <= bag.red && cube.green <= bag.green && cube.blue <= bag.blue
  end
end

defmodule ElfGame do
  def parse_game(game_string) do
    [id_string | rounds] = String.split(game_string, ": ")
    id = String.to_integer(String.replace(id_string, "Game ", ""))

    game = Game.new(id)

    Enum.reduce(rounds, game, fn round, game ->
      cube = parse_round(round)
      Game.add_round(game, cube)
    end)
  end

  def parse_round(round_string) do
    rounds = String.split(round_string, "; ")

    Enum.map(rounds, fn round ->
      counts_and_colors = String.split(round, ", ")

      for count_and_color <- counts_and_colors, reduce: Cube.new(0, 0, 0) do
        cube ->
          [count, color] = String.split(count_and_color, " ")

          case color do
            "red" -> %{cube | red: cube.red + String.to_integer(count)}
            "green" -> %{cube | green: cube.green + String.to_integer(count)}
            "blue" -> %{cube | blue: cube.blue + String.to_integer(count)}
          end
      end
    end)
  end

  def possible_games(games, bag) do
    Enum.filter(games, fn game ->
      Enum.all?(game.rounds, fn round ->
        Enum.all?(round, &Cube.possible?(&1, bag))
      end)
    end)
  end

  def sum_ids(games) do
    Enum.reduce(games, 0, fn game, acc -> game.id + acc end)
  end
end
