def parse(input)
    # it should look like:
    # {
    #     'parts' : [
    #         [xl, xr, y, number]
    #     ]
    #     'symbols': [
    #         [[x, y], symbol]
    #     ]
    # }
    
end

def matching_numbers(line)
    line = line.gsub(/Card\s+\d+:/, '')
    (winning_numbers, owned_numbers) = line.split(' | ').map{|nums| nums.split.map(&:to_i)}
    winning_numbers.intersection(owned_numbers).size
end

def part_1(input)
    input.split(/\n/).map.with_index do |line, i|
        matching_count = matching_numbers(line)
        (matching_count > 0) ? (2 ** (matching_count - 1)) : 0
    end.sum
end

def part_2(input)
    copies = []
    lines = input.split(/\n/)
    lines.each { |_| copies << 1 }
    lines.each_with_index do |line, i|
        ((i+1)..([i + matching_numbers(line), lines.size - 1].min)).each do |j|
            copies[j] += copies[i]
        end
    end

    copies.sum
end

input = <<END
Card 102: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
Card 7: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 8:  1  2  3  4  5 |  1  2  3  4  5  6  7  8
END
puts parse(input)
raise "test error 1 #{part_1(input)} != 31" unless part_1(input) == 31

input = <<END
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
END

raise "test error 2 #{part_2(input)} != 30" unless part_2(input) == 30

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)