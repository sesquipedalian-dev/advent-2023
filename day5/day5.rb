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
                sl: source, 
                sr: source + length - 1,
                dl: destination,
                dr: destination + length - 1
            }
        end
    end

    # order ranges 
    ranges.each do |range_list| 
        # order in source domain
        range_list.sort_by!{|a| a[:sl]}

        # insert a synthetic 0 - min range if not present
        unless range_list.first[:sl] == 0
            range_list.insert 0, {
                sl: 0,
                sr: range_list.first[:sl] - 1,
                dl: 0,
                dr: range_list.first[:sl] - 1
            }
        end

        # insert additional synthetics to cover any other gaps between ranges
        synthetic_ranges = []
        (0...(range_list.size - 1)).each do |i|
            next unless intersect?(range_list[i], range_list[i+1])

            synthetic_ranges << {
                sl: range_list[i][:sr] + 1,
                sr: range_list[i+1][:sl] - 1,
                dl: range_list[i][:sl] + 1,
                dr: range_list[i+1][:sl] - 1,
            }
        end
        synthetic_ranges.each{|sr| range_list.append(sr)}
        range_list.sort_by!{|a| a[:sl]}
    end
    
    [seeds, ranges]
end

def intersect?(lhs, rhs)
    # if two ranges like [xl, len], [x, len] overlap, assume lhs < rhs
    (lhs[:sl] <= rhs[:sl]) && (rhs[:sl] <= lhs[:sr])
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
        
        if ( range[:sl] <= source) && (source <= range[:sr])
            [true, range[:dl] + source - range[:sl]]
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
    # construct new seed ranges, [source, length]
    new_seeds = seeds.each_slice(2).map do |start, len|
        {
            sl: start,
            sr: start + len - 1
        }
    end

    # continually expand seed ranges into ranges in the destination space by looking for intersections
    # e.g. 
    # current seed range = [0, 50]
    # next space source ranges: [0, 25], [25, 50]
    # next iteration should expand seed range to [0, 25] AND [25, 25] with destination mapped 
    # #
    final_ranges = ranges.inject(new_seeds) do |current_seeds, range_list|
        next_seeds = []
        current_seeds.map do |seed|
            # find intersecting range in r
            while seed[:sl] <= seed[:sr]
                range = range_list.find {|range| (range[:sl] <= seed[:sl]) && (seed[:sl] <= range[:sr]) }

                unless range
                    # if no range found it doesn't change in the next round
                    next_seeds.append(seed)
                    break
                end

                # if an intersecting range is found, 
                # create a range up to the max of our current seed right or the target range's right, whichever is smaller
                range_end = [range[:sr], seed[:sr]].min
                range_start_offset = seed[:sl] - range[:sl]
                len = range_end - seed[:sl] + 1
                
                next_seeds.append({
                    sl: range[:dl] + range_start_offset,
                    sr: range[:dl] + range_start_offset + len - 1
                })

                # next round we'll start from the range end + 1
                seed = {
                    sl: range_end + 1,
                    sr: seed[:sr]
                }
            end
        end

        # iterate the next set of ranges
        next_seeds.sort_by{|s| s[:sl]}
    end

    # now final ranges is a list of ranges in the final destination space,
    # the goal of the puzzle is to find the lowest end of the lowest range
    final_ranges.first[:sl]
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

# 248892167 is too high 
# 7873084 is right :)
puts part_2(seeds, ranges)