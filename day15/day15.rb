def hash(string)
    current = 0
    string.each_byte do |next_ascii|
        current += next_ascii
        current *= 17
        current = current % 256
    end
    current
end

def part_1(input)
    input.split(',')
        .map{|s| s.gsub(/\n/, '')}
        .map do |s|
            hash(s)
        end.sum
end

class Insert
    attr_accessor :label, :focal_length

    def initialize(label, focal_length)
        @label = label
        @focal_length = focal_length
    end

    def exec(hashmap)
        hash_key = hash(@label)
        current_arr = hashmap[hash_key] || []
        index = current_arr.index {|label, _| label == @label}
        if index
            current_arr.delete_at(index)
            current_arr.insert(index, [label, @focal_length])
        else
            current_arr.push([label, @focal_length])
        end
        hashmap.merge(hash_key => current_arr)
    end
end

class Remove
    attr_accessor :label
    def initialize(label)
        @label = label
    end

    def exec(hashmap)
        hash_key = hash(@label)
        new_arr = (hashmap[hash_key] || []).filter{|label, focal_length| label != @label}
        hashmap.merge(hash_key => new_arr)
    end
end

def print_hash(hash)
    hash.keys.sort.each do |k|
        next if hash[k].empty?

        print "Box #{k}: "
        hash[k].each {|p| print "[#{p[0]} #{p[1]}]"}
    end
    puts "\n"
end

def focusing_power(hash)
    hash.keys.map do |k|
        hash[k].map.with_index do |(_, focal_length), slot|
            (k+1) * (slot + 1) * focal_length
        end.sum
    end.sum
end

def part_2(input)
    initialization_steps = input.split(',')
        .map{|s| s.gsub(/\n/, '')}
        .map do |d|
            label, op, focal_length = d.split(/(=|-)/)
            op == '=' ? Insert.new(label, focal_length.to_i) : Remove.new(label)
        end

    hash = {}
    initialization_steps.each do |step| 
        hash = step.exec(hash)
    end

    focusing_power(hash)
end

input = <<END
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
END
actual = part_1(input)
raise "test error 1 #{actual} != 1320" unless actual == 1320

actual = part_2(input)
raise "test error 2 #{actual} != 145" unless actual == 145

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)
