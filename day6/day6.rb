

def part_1(input)
    lines = input.split(/\n/)
        .map{ |l| l.split(/:\s+/)[1] }
        .map{ |l| l.split(/\s+/).map(&:to_i)}

    races = []
    lines[0].each {|time| races << [time]}
    lines[1].each_with_index { |record, i| races[i] << record}

    races.inject(1) do |product, race|
        ways_to_beat = (1...race[0]).count do |hold_button_duration|
            race[1] < (hold_button_duration * (race[0] - hold_button_duration))
        end
        product * ways_to_beat
    end
end

def part_2(input)
    # it ain't pretty but quick enough, < 1 min
    lines = input.split(/\n/)
    .map{ |l| l.split(/:\s+/)[1] }
    .map{ |l| l.gsub(/\s+/, '').to_i}

    time, record = lines

    (1...time).count do |hold_button_duration|
        record < (hold_button_duration * (time - hold_button_duration))
    end
end

input = <<END
Time:      7  15   30
Distance:  9  40  200
END
raise "test error 1 #{part_1(input)} != 288" unless part_1(input) == 288

raise "test error 2 #{part_2(input)} != 71503" unless part_2(input) == 71503

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)