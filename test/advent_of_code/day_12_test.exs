defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  import AdventOfCode.Day12

  test "part1" do
    result = part1(input())

    assert 21 == result
  end

  # @tag timeout: 600_000
  test "part2" do
    result = part2(input())

    assert 525_152 == result
  end

  def input do
    """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
  end
end
