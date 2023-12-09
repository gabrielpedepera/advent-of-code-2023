defmodule AdventOfCode.Day09Test do
  use ExUnit.Case

  import AdventOfCode.Day09

  test "part1" do
    result = part1(input())

    assert 114 == result
  end

  test "part2" do
    result = part2(input())

    assert 2 == result
  end

  def input do
    """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
  end
end
