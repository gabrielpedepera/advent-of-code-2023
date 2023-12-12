defmodule AdventOfCode.Day11Test do
  use ExUnit.Case

  import AdventOfCode.Day11

  test "part1" do
    result = part1(input())

    assert 374 == result
  end

  test "part2 with factor of 10" do
    result = part2(10, input())

    assert 1030 == result
  end

  test "part2 with factor of 100" do
    result = part2(100, input())

    assert 8410 == result
  end

  defp input do
    """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """
  end
end
