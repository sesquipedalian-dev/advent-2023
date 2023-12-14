def parse(input)
    input.split(/\n/).map do |row|
        row.split('')
    end
end

def part_1(grid)
    grid_rows = grid.size
    column_highest_blocker = grid[0].map{|_| -1}
    sum = 0
    grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
            case c
            when 'O'
                resting_place = column_highest_blocker[x] + 1
                column_highest_blocker[x] = resting_place
                sum += grid_rows - resting_place
            when '#'
                column_highest_blocker[x] = y
            end
        end
    end
    sum
end

input = <<END
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
END

grid = parse(input)
actual = part_1(grid)
raise "test error 1 #{actual} != 136" if actual != 136

input = File.read("input.txt")
grid = parse(input)
puts part_1(grid)