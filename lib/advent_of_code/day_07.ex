defmodule AdventOfCode.Day07 do
  @input AdventOfCode.Input.get!(7, 2023)

  @card_order ~w(A K Q J T 9 8 7 6 5 4 3 2)
  @type_order ~w(five_of_a_kind four_of_a_kind full_house three_of_a_kind two_pair one_pair high_card)

  def part1(input \\ @input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&add_sort_deck/1)
    |> Enum.map(&add_type/1)
    |> rank_hands()
    |> Enum.map(fn hand -> hand.rank * hand.bid end)
    |> Enum.sum()
  end

  def part2(_args) do
  end

  defp parse_line(line) do
    [deck, bid] = String.split(line)
    deck = String.split(deck, "", trim: true)
    bid = String.to_integer(bid)
    %{deck: deck, bid: bid}
  end

  def rank_hands(hands) do
    hands
    |> Enum.sort_by(&hand_rank/1)
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> Map.put(hand, :rank, rank) end)
  end

  defp hand_rank(%{type: type, deck: deck}) do
    type_rank = Enum.find_index(@type_order, &(&1 == Atom.to_string(type)))
    card_ranks = Enum.map(deck, &card_rank/1)
    {type_rank, card_ranks}
  end

  defp card_rank(card) do
    Enum.find_index(@card_order, &(&1 == card))
  end

  def add_type(hand) do
    type = type(hand.deck_sorted)
    Map.put(hand, :type, type)
  end

  def type([a, a, a, a, a]), do: :five_of_a_kind
  def type([a, a, a, a, _]), do: :four_of_a_kind
  def type([a, a, a, b, b]), do: :full_house
  def type([a, a, a, _, _]), do: :three_of_a_kind
  def type([a, a, b, b, _]), do: :two_pair
  def type([a, a, _, _, _]), do: :one_pair
  def type([_, _, _, _, _]), do: :high_card

  def add_sort_deck(%{deck: deck} = hand) do
    deck_sorted =
      deck
      |> Enum.group_by(& &1)
      |> Enum.map(fn {card, cards} ->
        {card, cards, Enum.find_index(@card_order, &(&1 == card))}
      end)
      |> Enum.sort_by(fn {_, cards, idx} -> {length(cards), -idx} end, &>=/2)
      |> Enum.flat_map(fn {_card, cards, _} -> sort_cards(cards) end)

    Map.put(hand, :deck_sorted, deck_sorted)
  end

  defp sort_cards(cards) do
    Enum.sort(cards, fn card1, card2 ->
      Enum.find_index(@card_order, &(&1 == card1)) >= Enum.find_index(@card_order, &(&1 == card2))
    end)
  end
end
