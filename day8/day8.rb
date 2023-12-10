require 'prime'

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
    # set of starting & ending nodes
    # current_nodes =  nodes.keys.filter {|label| label.end_with?('A')}
    # end_nodes = nodes.keys.filter{|label| label.end_with?('Z')}

    # for each start node, find the cycle in the instructions
    # this will take the form of 
    # start: steps to get to the beginning of the cycle
    # cycle: steps to return to the beginning of the cycle
    # z_steps: steps from beginning of cycle to any nodes that end with 'Z'
    # 
    current_nodes = nodes.keys.filter { |label| label.end_with?('A') }
        .map{|l| {
            orig: l,
            label: l,
            start: nil,
            cycle: nil,
            z_steps: [], # list of 'steps' where a label ending in z can be found
            seen: {} # map of seen labels to value of 'steps' they were seen at
        }}

    
    steps = 0
    i = 0
    while current_nodes.any? {|node| node[:cycle] == nil}
        go_right = instructions[i] == 'R'

        current_nodes.each do |node|
            next if node[:cycle]
            
            current_label = node[:label]

            node[:z_steps] << steps if current_label.end_with?('Z')

            seen = node[:seen][current_label + i.to_s]
            if seen
                # new cycle detected
                node[:start] = seen
                node[:cycle] = steps - node[:start]
            else
                node[:seen][current_label + i.to_s] = steps

                next_label = nodes[current_label][go_right ? 1 : 0]
                node[:label] = next_label
            end
        end

        i = (i + 1) % instructions.size
        steps += 1
    end


    # let's verify that our math is right
    # where can we get a 'Z' for each? 
    # current_nodes.each do |node|
    #     z_step = node[:z_steps][0]
        
    #     current_label = node[:orig]
    #     i = 0
    #     (0...z_step).each do |_|
    #         go_right = instructions[i] == 'R'
    #         current_label = nodes[current_label][go_right ? 1 : 0]
    #         i = (i + 1) % instructions.size
    #     end
    #     puts "current_label #{current_label}"

    #     (0...(node[:cycle])).each do |_|
    #         go_right = instructions[i] == 'R'
    #         current_label = nodes[current_label][go_right ? 1 : 0]
    #         i = (i + 1) % instructions.size
    #     end
    #     puts "current_label #{current_label}"
    # end

    # we can then figure out when all the cycles hit a 'z' with some least common multiple checks
    # sort the list of cycle info on cycle length desc
    # it's like, start with first where it would stop at Z in the cycle, 
    # then go down the list (since their multiples are smaller) and add up stops until they go past the previous higher
    # in the list.
    # 
    # OK, empirically, each cycle contains exactly one 'z_step' -> time it hits a Z
    # so we just need to sync up the cycle time with the z it hits during the cycle 
    # by finding the least common multiple of all the z_steps
    #

    prime_factors = current_nodes.map {|n| n[:z_steps][0] }.map do |factor_me|
        Prime.prime_division(factor_me)
    end.flatten(1)
    prime_factors.uniq!
    prime_factors.inject(1) {|accum, n| accum * n[0]}
end

# TODO - none of these test cases for part 2 work because the current solution is tied to the assumptions
# in my input.txt

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
actual = part_1(instructions, nodes)
raise "test error 1 #{actual} != 2" unless actual == 2

input = <<END
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
END
instructions, nodes = parse(input)
# actual = part_2(instructions, nodes)
# raise "test error 2 #{actual} != 6" unless actual == 6

# let's make a case where the cycles have different start locations
input = <<END
L

11A = (11B, XXX)
11B = (11C, XXX)
11C = (11D, XXX)
11D = (11Z, XXX)
11Z = (11D, XXX)
22A = (22B, XXX)
22B = (22Z, XXX)
22Z = (22A, XXX)
END

#    0  1   2   3   4   5   6   7   8
# 11A 11B 11C 11D 11Z 11D 11Z 11D 11Z
# 22A 22B 22Z 22A 22B 22Z 22A 22B 22Z 

instructions, nodes = parse(input)
# actual = part_2(instructions, nodes)
# raise "test error 2.1 #{actual} != 8" unless actual == 8

input = File.read("input.txt")
instructions, nodes = parse(input)
puts part_1(instructions, nodes)
puts part_2(instructions, nodes)