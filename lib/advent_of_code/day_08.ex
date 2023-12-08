defmodule AdventOfCode.Day08 do
  @input AdventOfCode.Input.get!(8, 2023)
  def part1(input \\ @input) do
    input
    |> Camel.parse()
    |> Camel.solve()
  end

  def part2(_args) do
  end
end

defmodule Camel do
  defstruct [:steps, :network, :current, :step_index, :steps_count]

  def solve(input) do
    %{steps: steps, network: network} = input
    state = %Camel{steps: steps, network: network, current: "AAA", step_index: 0, steps_count: 0}
    bfs(state)
  end

  def parse(input) do
    [steps_line | network_lines] = String.split(input, "\n\n")

    steps =
      String.split(steps_line, "")
      |> Enum.reject(&(&1 == ""))

    network =
      network_lines
      |> Enum.map(&String.split(&1, "\n"))
      |> List.flatten()
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.split(&1, " = "))
      |> Enum.map(fn [node, edges] ->
        {node, String.split(String.replace(edges, ~r/[()]/, ""), ", ")}
      end)
      |> Enum.into(%{})

    network =
      Enum.map(network, fn {k, v} -> {k, %{"L" => Enum.at(v, 0), "R" => Enum.at(v, 1)}} end)
      |> Enum.into(%{})

    %{steps: steps, network: network}
  end

  defp bfs(%Camel{current: "ZZZ", steps_count: steps_count}), do: steps_count

  defp bfs(state) do
    next_step = Enum.at(state.steps, rem(state.step_index, length(state.steps)))
    next_node = Map.get(state.network, state.current)[next_step]

    bfs(%{
      state
      | current: next_node,
        step_index: state.step_index + 1,
        steps_count: state.steps_count + 1
    })
  end
end
