def parse(input)
    # output
    # [ 
    #     [ #game
    #         [ # round 
    #         [3, blue], [4, red]
    #         ],
    #     ]
    # ]
    games = input.split(/\n/)
    games = games.map do |game|
        (_, record_part) = game.split(':')
        record_part.strip!
        rounds = record_part.split(';').map(&:strip)
        rounds.map do |round|
            parts = round.split(',').map(&:strip)
            parts.map do |part|
                (count, color) = part.split(/\s+/)
                [count.to_i, color]
            end
        end
    end
end

def part_1(input)
    games = parse(input)

    # what games would be possible
    max_cubes = {
        'red' => 12,
        'green'=> 13,
        'blue'=> 14
    }

    sum = 0
    games.each_with_index do |game, i|
        possible = game.inject(true) do |game_accum, round|
            game_accum && round.inject(true) do |round_accum, (count, color)|
                round_accum && (count <= (max_cubes[color] || 0))
                # puts "foo #{i} #{valid}, #{color}, #{max_cubes[color]}, #{max_cubes[color] || 0}"
            end
        end
        sum += (i + 1) if possible
    end

    sum
end

def part_2(input)
    games = parse(input)

    # determine a minimum set of cubes per game 
    games.each_with_index.inject(0) do |power_accum, (game, i)|
        min_cubes = {
            'red' => 0,
            'green' => 0,
            'blue' => 0
        }

        game.each do |round|
            round.each do |(count, color)|
                # assign new max to min_cubes if we need more
                min_cubes[color] = [min_cubes[color], count].sort.last
            end
        end

        power = min_cubes.each_value.inject(1) { |accum, n| accum * n}
        power_accum += power
    end
end

input = <<END
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
END

# puts parse(input)
raise "test error 1 #{part_1(input)} != 8" unless part_1(input) == 8

raise "test error 2 #{part_2(input)} != 2286" unless part_2(input) == 2286

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)