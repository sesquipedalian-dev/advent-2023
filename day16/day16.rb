RIGHT = [0, 1]
LEFT = [0, -1]
UP = [-1, 0]
DOWN = [1, 0]

def parse(input)
    grid = input.split(/\n/).map do |line|
        line.split('').map do |s|
            symbol = case s
                when '.'
                    {
                        RIGHT => [RIGHT], 
                        LEFT => [LEFT], 
                        UP => [UP], 
                        DOWN => [DOWN]
                    }
                when '-'
                    {
                        RIGHT => [RIGHT],
                        LEFT => [LEFT], 
                        UP => [LEFT, RIGHT],
                        DOWN => [LEFT, RIGHT]
                    }
                when '|'
                    {
                        RIGHT => [UP, DOWN], 
                        LEFT => [UP, DOWN],
                        UP => [UP],
                        DOWN => [DOWN]
                    }
                when '\\'
                    {
                        RIGHT => [DOWN], 
                        LEFT => [UP],
                        UP => [LEFT], 
                        DOWN => [RIGHT]
                    }
                when '/'
                    {
                        RIGHT => [UP], 
                        LEFT => [DOWN],
                        UP => [RIGHT], 
                        DOWN => [LEFT]
                    }
                end
            [symbol, false]
        end
    end
    
    [[[RIGHT, [0, 0]]], grid]
end

def in_bounds(grid, y, x)
    0 <= y && y < grid.size && 0 <= x && x < grid[0].size
end

def print_beam(beam)
    direction, (y, x) = beam
    print case direction
when UP
    '^'
when DOWN
    'v'
when RIGHT
    '>'
when LEFT
    '<'
end
    print " @ (#{y},#{x})\n"
end

def part_1(input)
    beams, grid = parse(input)
    seen = {}
    while !beams.empty?
        beams = beams
            .map do |direction, (y, x)|
                seen[[direction, [y, x]]] = true
                grid[y][x][1] = true
                new_directions = grid[y][x][0][direction]
                new_directions.map {|d| [d, [y, x]]}
            end
            .flatten(1)
            .map { |direction, (y, x)| [direction, [y + direction[0], x + direction[1]]]}
            .filter {|direction, (y, x)| !seen[[direction, [y, x]]] && in_bounds(grid, y, x)}
    end

    grid.map do |row|
        row.count {|_, seen| seen}
    end.sum
end


def part_2(input)

end

input = <<END
.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....
END
actual = part_1(input)
raise "test error 1 #{actual} != 46" unless actual == 46

input = <<END
\\..
\\.|
...
END
actual = part_1(input)
raise "test error 1.1 #{actual} != 6" unless actual == 6

# actual = part_2(input)
# raise "test error 2 #{actual} != 145" unless actual == 145

input = File.read("input.txt")
puts part_1(input)
# puts part_2(input)
