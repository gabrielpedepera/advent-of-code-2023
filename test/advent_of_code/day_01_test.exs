defmodule AdventOfCode.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Day01

  test "part1" do
    input =
      """
      1abc2\n
      pqr3stu8vwx\n
      a1b2c3d4e5f\n
      treb7uchet
      """

    result = part1(input)
    assert 142 == result
  end

  test "part2" do
    input =
      """
      two1nine\n
      eightwothree\n
      abcone2threexyz\n
      xtwone3four\n
      4nineeightseven2\n
      zoneight234\n
      7pqrstsixteen
      """

    result = part2(input)

    assert 281 == result
  end
end
