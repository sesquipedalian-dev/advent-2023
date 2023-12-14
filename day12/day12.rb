def parse(input)

end

def get_variants(data)
    i = data.index('?')
    return [data] unless i

    get_variants(data[0...i] + '.' + data[(i+1)..]) + get_variants(data[0...i] + '#' + data[(i+1)..])
end

def part_1(input)
    rejected = {} # [sequence of # lengths],[sequence of spec lengths] -> true
    count = 0

    input.split(/\n/).map do |line|
        data, spec = line.split(/\s+/)
        spec = spec.split(',').map(&:to_i)

        # get_variants(data)
        #   .map {|v| v.split('.')}
        #   .map {|v| v.filter{|s| !s.empty?}}
        #   .map {|v| v.map{|g| g.size}}
        #   .count{|v| v == spec}

        queue = vs.map{|v| [data, spec, 0]}
        puts queue.map{|v, spec| "#{v}, #{spec}"}
        while !queue.empty?
            current = queue.shift
            data, spec, i = current
            puts "chcking #{current}"

            next if rejected[current]
            
            if current.all?{|a| a.empty?}
                puts "counting"
                count += 1
                next
            end

            if spec.empty? && i != 0
                rejected[current] = true
                next
            end

            # and now wee account for the ?
            # find the next character that could NOT be a '#' - .
            # (for part 2 rolling over to the beginning x times, for part 1 the end terminates also0
            # the length of ?/# sequence will determine how many variations there can be for this step
            # e.g. need 2, length 4, 3 choices ('##..', '.##.', '..##')
            # but we need product together the variations that different steps of the spec enjoy?
            # e.g. ????? 2,2
            # hm but this doesn't give room for the other ones in the sequence

            next_sequence_spec = current[1][0]
            if lhs != rhs
                rejected[current] = true
                next
            end

            current[0].shift
            current[1].shift
            queue.push(current)
        end
    end

    count
end

def part_2(input)
    input.split(/\n/).map do |line|
        data, spec = line.split(/\s+/)

        # unfold
        data = [data, data, data, data, data].join('?')
        spec = [spec, spec, spec, spec, spec].join(',')
            .split(',')
            .map(&:to_i)

        vs = get_variants(data)
            .map{|vs| vs.split('.')}
            .map{|vs| vs.filter{|g| !g.empty?}}
            .map{|vs| vs.map(&:to_i)}

        vs.count {|v| v == spec}
    end.sum
end

input = <<END
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
END
actual = part_1(input)
raise "test error 1 #{actual} != 21" unless actual == 21

actual = part_2(input)
raise "test error 2 #{actual} != 525152" unless part_2(input) == 525152

input = File.read("input.txt")
puts part_1(input)
# puts part_2(input)