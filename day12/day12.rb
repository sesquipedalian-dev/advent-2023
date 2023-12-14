def parse(input, part_2=false)
    input.split(/[\n\r]/).map do |line|
        data, spec = line.split(/\s+/).map{|l| l.gsub(/[[:space:]]/, '')}

        if part_2
            data = [data, data, data, data, data].join('?')
            spec = [spec, spec, spec, spec, spec].join(',')
        end

        spec = spec.split(',').map(&:to_i)
        data = data.chars.map do |c|
            case c
            when '#'
                2
            when '?'
                1
            when '.'
                0
            end
        end

        [data, spec]
    end
end

def match_start(data, length)
    data[...length].all? {|d| d > 0} && (data.size == length || data[length]< 2)
end

MEMO = {}
def count(data, spec)
    return MEMO[[data, spec]] if MEMO.key?([data, spec])

    total = spec.sum
    minimum = data.filter{|x| x == 2}.count
    maximum = data.filter{|x| x > 0}.count

    result = if minimum > total || maximum < total
        0
    elsif total == 0 
        1
    elsif data.first == 0
        count(data[1..], spec) 
    elsif data.first == 2
        l = spec[0]
        if match_start(data, l)
            if l == data.size
                1
            else
                count(data[(l+1)..], spec[1..])
            end
        else
            0
        end
    else
        count(data[1..], spec) + count([2] + data[1..], spec)
    end

    MEMO[[data, spec]] = result
    return result
end

def sum(lines)
    lines.map{|data, spec| count(data, spec)}.sum
end


input = <<END
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
END
data = parse(input)
actual = sum(data)
raise "test error 1 #{actual} != 21" unless actual == 21

data = parse(input, part_2=true)
actual = sum(data)
raise "test error 2 #{actual} != 525152" unless actual == 525152

input = File.read("input.txt")
data = parse(input)
puts sum(data)
data = parse(input, part_2=true)
puts sum(data)