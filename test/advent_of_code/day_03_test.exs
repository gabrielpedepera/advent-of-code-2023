defmodule AdventOfCode.Day03Test do
  use ExUnit.Case

  import AdventOfCode.Day03

  test "part1" do
    result = part1(input())

    assert 4361 == result
  end

  test "part2" do
    result = part2(input())

    assert 467_835 == result
  end

  defp input() do
    """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """
  end
end
