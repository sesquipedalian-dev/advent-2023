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
    beams, grid = parse(input)
    max_row = grid.size - 1
    max_col = grid[0].size - 1

    running_max = -1
    (0..max_row).each do |starting_row|
        [[RIGHT, 0], [LEFT, max_col]].each do |direction, starting_col|
            _, grid = parse(input)
            beams = [[direction, [starting_row, starting_col]]]
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

            current_max = grid.map do |row|
                row.count {|_, seen| seen}
            end.sum
            # puts "running_max #{direction}#{starting_col} #{starting_row} #{running_max} #{current_max}"
            running_max = [current_max, running_max].sort.last
        end
    end

    (0..max_col).each do |starting_col|
        [[DOWN, 0], [UP, max_row]].each do |direction, starting_row|
            _, grid = parse(input)
            beams = [[direction, [starting_row, starting_col]]]
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

            current_max = grid.map do |row|
                row.count {|_, seen| seen}
            end.sum
            # puts "running_max #{direction}#{starting_col} #{starting_row} #{running_max} #{current_max}"
            running_max = [current_max, running_max].sort.last
        end
    end

    running_max
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

actual = part_2(input)
raise "test error 2 #{actual} != 51" unless actual == 51

input = <<END
\\..
\\.|
...
END
actual = part_1(input)
raise "test error 1.1 #{actual} != 6" unless actual == 6


input = File.read("input.txt")
puts part_1(input)
puts part_2(input)
