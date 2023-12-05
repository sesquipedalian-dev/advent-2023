def parse(input)
    
end

def part_1(input)

end

def part_2(input)

end

input = <<END

END
puts parse(input)
raise "test error 1 #{part_1(input)} != 31" unless part_1(input) == 31

# input = <<END

# END

# raise "test error 2 #{part_2(input)} != 30" unless part_2(input) == 30

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)