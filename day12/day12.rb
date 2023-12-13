def parse(input)

end

MEMO = {}
$used_memo_count = 0.0
$total_count = 0.0
def get_variants(data)
    $total_count = $total_count + 1
    if $total_count % 1000 == 0
        puts "memo usage% #{$used_memo_count / $total_count}"
    end
    i = data.index('?')
    unless i
        $used_memo_count += 1
        MEMO[data] = [data]
        return [data]
    end
    
    return MEMO[data] if MEMO.key? data

    vs = get_variants(data[0...i] + '.' + data[(i+1)..]) + get_variants(data[0...i] + '#' + data[(i+1)..])
    MEMO[data] = vs
    vs
end

def part_1(input)
    input.split(/\n/).map do |line|
        data, spec = line.split(/\s+/)
        spec = spec.split(',').map(&:to_i)

        vs = get_variants(data)
            .map{|vs| vs.split('.')}
            .map{|vs| vs.filter{|g| !g.empty?}}
            .map{|vs| vs.map{|g| g.size}}

        puts "checking line #{vs} #{spec} #{line}"

        vs.count {|v| v == spec}
    end.sum
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
puts part_2(input)