defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  import AdventOfCode.Day10

  test "part1 with input1" do
    result = part1(input1())

    assert 4 == result
  end

  test "part1 with input2" do
    result = part1(input2())

    assert 8 == result
  end

  test "part2 input1" do
    result = part2(input1_part2())

    assert 4 == result
  end

  test "part2 input2" do
    result = part2(input2_part2())

    assert 8 == result
  end

  test "part2 input3" do
    result = part2(input3_part2())

    assert 10 == result
  end

  def input1 do
    """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """
  end

  def input2 do
    """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """
  end

  def input1_part2 do
    """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
  end

  def input2_part2 do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
  end

  def input3_part2 do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
  end
end
