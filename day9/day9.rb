def part_1(input)
  sum = 0
  lines = input.split(/\n/)
  lines.map do |line|
    nums = line.split(/\s+/).map(&:to_i)
    nums = [nums]

    # nums iterate until last row is all 0, getting differences of lines
    while nums.last.any?{|n| n != 0}
        next_line = []
        nums.last.each_cons(2) {|a, b| next_line << (b - a)}
        nums << next_line
    end

    # now add a 0 to the last line and bubble up to figure out what the value of the next at 0 should be
    nums.last << 0
    (nums.size - 1).downto(1).each do |i|
        nums[i-1] << nums[i-1].last + nums[i].last
    end

    sum += nums[0].last
  end

  sum
end

def part_2(input)
    sum = 0
    lines = input.split(/\n/)
    lines.map do |line|
      nums = line.split(/\s+/).map(&:to_i)
      nums = [nums]
  
      # nums iterate until last row is all 0, getting differences of lines
      while nums.last.any?{|n| n != 0}
          next_line = []
          nums.last.each_cons(2) {|a, b| next_line << (b - a)}
          nums << next_line
      end
  
      # now add a 0 to the last line and bubble up to figure out what the value of the next at 0 should be
      nums.last.insert(0, 0)
      (nums.size - 1).downto(1).each do |i|
          nums[i-1].insert(0, nums[i-1].first -  + nums[i].first)
      end
  
      sum += nums[0].first
    end
  
    sum
end

input = <<END
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
END
actual = part_1(input)
raise "test error 1 #{actual} != 114" unless actual == 114

actual = part_2(input)
raise "test error 2 #{actual} != 2" unless actual == 2

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)