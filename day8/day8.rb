def parse(input)
    lines = input.split(/\n/)
    instructions = lines.shift
    lines.shift

    # {
        # label => [left, right]
    # }
    nodes = {}
    lines.each do |line|
        label, left, right = line.split(/ = \(|, |\)/)
        nodes[label] = [left, right]
    end

    [instructions, nodes]
end

def part_1(instructions, nodes)
    steps = 0
    i = 0
    current_node = 'AAA'
    while current_node != 'ZZZ'
        go_right = instructions[i] == 'R'
        current_node = nodes[current_node][go_right ? 1 : 0]
        i = (i + 1) % instructions.size
        steps += 1
    end

    steps
end

def part_2(instructions, nodes)

end

input = <<END
RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)
END
instructions, nodes = parse(input)
puts instructions, nodes
actual = part_1(instructions, nodes)
raise "test error 1 #{actual} != 2" unless actual == 2

# input = <<END

# END

# raise "test error 2 #{part_2(input)} != 30" unless part_2(input) == 30

input = File.read("input.txt")
instructions, nodes = parse(input)
puts part_1(instructions, nodes)
# puts part_2(input)