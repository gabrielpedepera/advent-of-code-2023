defmodule AdventOfCode.Day07 do
  @input AdventOfCode.Input.get!(7, 2023)

  @card_order ~w(A K Q J T 9 8 7 6 5 4 3 2)
  @card_order_with_joker ~w(A K Q T 9 8 7 6 5 4 3 2 J)

  @label_order ~w(five_of_a_kind four_of_a_kind full_house three_of_a_kind two_pair one_pair high_card)

  def part1(input \\ @input) do
    label_function = &label/1

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&add_sort_deck(&1, @card_order))
    |> Enum.map(&add_label(&1, label_function))
    |> rank_hands(@card_order)
    |> calculate_total_winnings()
  end

  def part2(input \\ @input) do
    label_function = &label_with_jokers/1

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&add_sort_deck(&1, @card_order_with_joker))
    |> Enum.map(&add_label(&1, label_function))
    |> rank_hands(@card_order_with_joker)
    |> calculate_total_winnings()
  end

  defp calculate_total_winnings(hands) do
    Enum.reduce(hands, 0, fn hand, acc ->
      acc + hand.rank * hand.bid
    end)
  end

  defp label_with_jokers(deck_sorted) do
    joker_count = Enum.count(deck_sorted, &(&1 == "J"))
    other_cards = Enum.reject(deck_sorted, &(&1 == "J"))

    cond do
      can_be_five_of_a_kind?(other_cards, joker_count) -> :five_of_a_kind
      can_be_four_of_a_kind?(other_cards, joker_count) -> :four_of_a_kind
      can_be_full_house?(other_cards, joker_count) -> :full_house
      can_be_three_of_a_kind?(other_cards, joker_count) -> :three_of_a_kind
      can_be_two_pair?(other_cards, joker_count) -> :two_pair
      can_be_one_pair?(other_cards, joker_count) -> :one_pair
      true -> :high_card
    end
  end

  defp can_be_five_of_a_kind?(other_cards, joker_count) do
    max_same_card_count = max_same_card_count(other_cards)
    max_same_card_count + joker_count >= 5
  end

  defp can_be_four_of_a_kind?(other_cards, joker_count) do
    max_same_card_count = max_same_card_count(other_cards)
    max_same_card_count + joker_count >= 4
  end

  defp can_be_full_house?(other_cards, joker_count) do
    card_counts =
      Enum.group_by(other_cards, & &1) |> Enum.map(fn {_card, cards} -> length(cards) end)

    count_of_triples_or_more = Enum.count(card_counts, &(&1 >= 3))
    count_of_pairs_or_more = Enum.count(card_counts, &(&1 >= 2))

    (count_of_triples_or_more > 0 and count_of_pairs_or_more > 1) or
      (count_of_triples_or_more + joker_count >= 1 and count_of_pairs_or_more > 1) or
      (count_of_triples_or_more > 0 and count_of_pairs_or_more > 0 and joker_count > 0)
  end

  defp can_be_three_of_a_kind?(other_cards, joker_count) do
    max_same_card_count = max_same_card_count(other_cards)
    max_same_card_count + joker_count >= 3
  end

  defp can_be_two_pair?(other_cards, joker_count) do
    card_counts =
      Enum.group_by(other_cards, & &1) |> Enum.map(fn {_card, cards} -> length(cards) end)

    count_of_pairs = Enum.count(card_counts, &(&1 >= 2))
    count_of_pairs + joker_count >= 2
  end

  defp can_be_one_pair?(other_cards, joker_count) do
    max_same_card_count = max_same_card_count(other_cards)
    max_same_card_count + joker_count >= 2
  end

  defp max_same_card_count([]), do: 0

  defp max_same_card_count(cards) do
    cards
    |> Enum.group_by(& &1)
    |> Enum.map(fn {_card, cards} -> length(cards) end)
    |> Enum.max()
  end

  defp parse_line(line) do
    [deck, bid] = String.split(line)
    deck = String.split(deck, "", trim: true)
    bid = String.to_integer(bid)
    %{deck: deck, bid: bid}
  end

  defp rank_hands(hands, order) do
    hands
    |> Enum.sort_by(&hand_rank(&1, order))
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> Map.put(hand, :rank, rank) end)
  end

  defp hand_rank(%{label: label, deck: deck}, order) do
    label_rank = Enum.find_index(@label_order, &(&1 == Atom.to_string(label)))
    card_ranks = Enum.map(deck, &card_rank(&1, order))
    {label_rank, card_ranks}
  end

  defp card_rank(card, order) do
    Enum.find_index(order, &(&1 == card))
  end

  defp add_label(hand, function_label) do
    label = function_label.(hand.deck_sorted)
    Map.put(hand, :label, label)
  end

  defp label([a, a, a, a, a]), do: :five_of_a_kind
  defp label([a, a, a, a, _]), do: :four_of_a_kind
  defp label([a, a, a, b, b]), do: :full_house
  defp label([a, a, a, _, _]), do: :three_of_a_kind
  defp label([a, a, b, b, _]), do: :two_pair
  defp label([a, a, _, _, _]), do: :one_pair
  defp label([_, _, _, _, _]), do: :high_card

  defp add_sort_deck(%{deck: deck} = hand, order) do
    deck_sorted =
      deck
      |> Enum.group_by(& &1)
      |> Enum.map(fn {card, cards} ->
        {card, cards, Enum.find_index(order, &(&1 == card))}
      end)
      |> Enum.sort_by(fn {_, cards, idx} -> {length(cards), -idx} end, &>=/2)
      |> Enum.flat_map(fn {_card, cards, _} -> sort_cards(cards, order) end)

    Map.put(hand, :deck_sorted, deck_sorted)
  end

  defp sort_cards(cards, order) do
    Enum.sort(cards, fn card1, card2 ->
      Enum.find_index(order, &(&1 == card1)) >= Enum.find_index(order, &(&1 == card2))
    end)
  end
end
