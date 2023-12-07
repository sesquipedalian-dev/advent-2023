
SYMBOL_PRIORITY = [
    'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'
]

SYMBOL_PRIORITY_PART_2 = [
    'A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J'
]

SYMBOLS = 0
BID = 1
RANK = 2

# if lhs is 'stronger' 1
# else -1
def comp_symbols(lhs, rhs, symbol_priority)
    return 0 if lhs == rhs

    sym_pairs = lhs.zip(rhs)

    sym_pairs.each do |l, r|
        diff = symbol_priority.index(r) - symbol_priority.index(l)
        return diff if diff != 0
    end
    0
end


SYMBOL_COUNTS_PRIORITY = [
    [5],  # strongest
    [4, 1],
    [3, 2],
    [3, 1, 1],
    [2, 2, 1],
    [2, 1, 1, 1],
    [1, 1, 1, 1, 1] # weakest
]

def symbols_to_type_score(symbols)
    # Five of a kind, where all five cards have the same label: AAAAA
    # Four of a kind, where four cards have the same label and one card has a different label: AA8AA
    # Full house, where three cards have the same label, and the remaining two cards share a different label: 23332
    # Three of a kind, where three cards have the same label, and the remaining two cards are each different from any other card in the hand: TTT98
    # Two pair, where two cards share one label, two other cards share a second label, and the remaining card has a third label: 23432
    # One pair, where two cards share one label, and the other three cards have a different label from the pair and each other: A23A4
    # High card, where all cards' labels are distinct: 23456

    counts = symbols.inject({}) do |accum, s| 
        accum.merge({ s => (accum[s] || 0) + 1 })
    end
    counts = counts.values.sort.reverse
    SYMBOL_COUNTS_PRIORITY.index(counts)
end

def symbols_to_type_score_part_2(symbols)
    # same as p1 unless 'J' is present, then we try all the variations and pick the strongest

    first_index_of_j = symbols.join.index('J')

    if first_index_of_j
        before = symbols[0...first_index_of_j]
        after = symbols[(first_index_of_j + 1)..]
        min_rank = 1000
        SYMBOL_PRIORITY_PART_2.each do |sym|
            next if sym == 'J'

            new_min = symbols_to_type_score_part_2([before, sym, after].flatten)
            min_rank = [min_rank, new_min].min
        end
        min_rank
    else
        symbols_to_type_score(symbols)
    end
end

def parse(input, part_2 = false)
    input.split(/\n/)
        .map{|l| l.split}
        .map{|symbols, bid| [symbols.split(''), bid.to_i]}
        .map{|h| h << (part_2 ? symbols_to_type_score_part_2(h[SYMBOLS]) : symbols_to_type_score(h[SYMBOLS]))}
end

def part_1(hands, symbol_priority = SYMBOL_PRIORITY)
    # sort the hands by their 'strength'
    hands.sort! do |lhs, rhs| 
        if lhs[RANK] == rhs[RANK]
            comp_symbols(lhs[SYMBOLS], rhs[SYMBOLS], symbol_priority)
        else
            rhs[RANK] - lhs[RANK]
        end
    end

    sum = 0
    hands.each_with_index { |h, i| sum += h[BID] * (i + 1)}
    sum
end


input = <<END
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
END
hands = parse(input)
# hands.each do |h|
#     puts "hand #{h[SYMBOLS].join}, #{h[BID]} #{h[RANK]}"
# end
actual = part_1(hands)
raise "test error 1 #{actual} != 6440" unless actual == 6440

# test some variations with the same rank (a longer list?)
input = <<END
AAAA8 8
7A777 1
QQQJQ 2
KKKK3 5
AJAAA 6
AAAA7 7
QAQQQ 3
KKK9K 4
END
hands = parse(input)
expected = (1..8).map{|i| i**2}.sum
actual = part_1(hands)
raise "test error 1.5 #{actual} != #{expected}" unless actual == expected

input = <<END
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
END
hands = parse(input, true)
# hands.each do |h|
#     puts "hand #{h[SYMBOLS].join}, #{h[BID]} #{h[RANK]}"
# end
actual = part_1(hands, SYMBOL_PRIORITY_PART_2)
raise "test error 2 #{actual} != 5905" unless actual == 5905

input = File.read("input.txt")
hands = parse(input)
# hands.each do |h|
#     puts "hand #{h[SYMBOLS].join}, #{h[BID]} #{h[RANK]}"
# end
puts part_1(hands)

hands = parse(input, true)
puts part_1(hands, SYMBOL_PRIORITY_PART_2)
253473930