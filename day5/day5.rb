def parse(input)
    # data looks like
    # [
    #     [ 1, 2, 3], # seeds
    #     [ # range data
    #         [
    #             {
    #                 source: 1,
    #                 destination: 2,
    #                 length: 5
    #             },
    #         ]
    #     ]
    # ]
    lines = input.split(/\n/)
    seed_line = lines.shift
    seeds = seed_line.split(': ')[1].split.map(&:to_i)

    ranges = []
    range_index = -1
    lines.each do |line|
        if line.empty?
            ranges << []
            range_index += 1
        elsif line.start_with?(/\d/)
            (destination, source, length) = line.split.map(&:to_i)
            ranges[range_index] << {
                source: source, 
                destination: destination, 
                length: length
            }
        end
    end
    
    [seeds, ranges]
end

def source_to_dest(source, range_info)
    # range_info 
    # [{
    #     source: 1,
    #     destination: 2,
    #     length: 5
    # },
    # ]

    r = range_info.inject([false, source]) do |found, range|
        next found if found[0]
        
        in_range_offset = source - range[:source]
        if (0 <= in_range_offset) && (in_range_offset < range[:length])
            [true, range[:destination] + in_range_offset]
        else
            found
        end
    end
    
    r[1]
end

def part_1(seeds, ranges)
    min_location = 2**64
    seeds.each do |seed|
        new_location = ranges.inject(seed){|source, range_info| source_to_dest(source, range_info)}
        min_location = [min_location, new_location].sort[0]
    end
    min_location
end

def part_2(seeds, ranges)
    # this is obviously not going to work for big inputs just on constructing the new seeds array
    new_seeds = []
    (0...seeds[1]).each { |i| new_seeds << (seeds[0] + i) }
    (0...seeds[3]).each { |i| new_seeds << (seeds[2] + i) }
    part_1(new_seeds, ranges)
end


input = <<END
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
END

(seeds, ranges) = parse(input)
# ranges.each do |range|
#     puts "range:", range
# end
# puts seeds
raise "test error 0.1 #{source_to_dest(51, ranges[0])}" unless source_to_dest(51, ranges[0]) == 53
raise "test error 0.2 #{source_to_dest(0, ranges[0])}" unless source_to_dest(0, ranges[0]) == 0
raise "test error 0.3 #{source_to_dest(98, ranges[0])}" unless source_to_dest(98, ranges[0]) == 50
raise "test error 1 #{part_1(seeds, ranges)} != 35" unless part_1(seeds, ranges) == 35

raise "test error 2 #{part_2(seeds, ranges)} != 46" unless part_2(seeds, ranges) == 46

input = File.read("input.txt")
seeds, ranges = parse(input)
puts part_1(seeds, ranges)
# puts part_2(seeds, ranges)