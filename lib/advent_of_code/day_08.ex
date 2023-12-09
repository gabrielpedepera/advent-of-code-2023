defmodule AdventOfCode.Day08 do
  @input AdventOfCode.Input.get!(8, 2023)
  def part1(input \\ @input) do
    input
    |> Camel.parse()
    |> Camel.solve()
  end

  def part2(input \\ @input) do
    input
    |> Camel.parse()
    |> Camel.solve_part2()
  end
end

defmodule Camel do
  defstruct [:steps, :network, :current, :step_index, :steps_count, :visited]

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

    %Camel{steps: steps, network: network}
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

  def solve_part2(input) do
    input
    |> get_pattern_for_starting_nodes()
    |> get_least_common_multiple()
  end

  defp get_pattern_for_starting_nodes(%{network: network} = state) do
    network
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(fn start_node ->
      steps_to_final_node(%{state | current: start_node, step_index: 0, steps_count: 0})
    end)
  end

  defp steps_to_final_node(
         %Camel{steps: instructions, network: network, current: current_node} = state,
         current_steps \\ 0
       ) do
    if String.ends_with?(current_node, "Z") do
      current_steps
    else
      index = rem(current_steps, length(instructions))
      instruction = Enum.at(instructions, index)
      new_node = Map.get(network, current_node)[instruction]

      steps_to_final_node(%{state | current: new_node}, current_steps + 1)
    end
  end

  defp get_least_common_multiple(numbers) do
    leading_number = Enum.max(numbers)
    get_least_common_multiple(numbers, leading_number, leading_number)
  end

  defp get_least_common_multiple(numbers, leading_number, multiple) do
    if Enum.all?(numbers, &(rem(multiple, &1) === 0)) do
      multiple
    else
      get_least_common_multiple(numbers, leading_number, multiple + leading_number)
    end
  end
end
