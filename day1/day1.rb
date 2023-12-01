
def part_1(input)
  input
    .split
    .map {|l| l.gsub(/[^\d]/, '')}
    .map{|l| l.chars.first.to_i * 10 + l.chars.last.to_i}
    .inject(0) { |accum, n| accum + n}
end

DIGITS = {
    'one' => 1,
    'two' => 2,
    'three' => 3,
    'four' => 4,
    'five' => 5,
    'six' => 6,
    'seven' => 7,
    'eight' => 8,
    'nine' => 9
    # I checked and did not find 'zero' in my inputs, nor does the puzzle mention it
}
def part_2(input)
  input = input
    .split
    .map {|l| l.scan(/(?=(one|two|three|four|five|six|seven|eight|nine|\d))/)}
    .map {|a| a.map{|digit_string| DIGITS[digit_string.first] || digit_string.first.to_i}}
    .map{|l| l.first.to_i * 10 + l.last.to_i}
    .inject(0) { |accum, n| accum + n}
end

input = <<END
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
END

raise 'test error 1' unless part_1(input) == 142

input = <<END
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
END

raise "test error 2 #{part_2(input)} != 281" unless part_2(input) == 281

input = File.read("puzzle_input.txt")
puts part_1(input)
puts part_2(input)