defmodule AdventOfCode.Day07Test do
  use ExUnit.Case

  import AdventOfCode.Day07

  test "part1" do
    result = part1(input())

    assert 6440 = result
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end

  defp input do
    """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
  end
end
