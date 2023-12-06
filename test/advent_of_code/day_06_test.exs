defmodule AdventOfCode.Day06Test do
  use ExUnit.Case

  import AdventOfCode.Day06

  test "part1" do
    result = part1(input())

    assert 288 == result
  end

  test "part2" do
    result = part2(input())

    assert 71503 = result
  end

  defp input do
    """
    Time:      7  15   30
    Distance:  9  40  200
    """
  end
end
