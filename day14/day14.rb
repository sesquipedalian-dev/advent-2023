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
                
                grid[y][x] = '.'
                grid[resting_place][x] = 'O'
                sum += grid_rows - resting_place
            when '#'
                column_highest_blocker[x] = y
            end
        end
    end
    [grid, sum]
end

#
# 123
# 456
# 789
#
# 741
# 852
# 963
#
# I hope the grids are square
#
def rotate_clockwise(grid)
    rows = grid.size
    cols = grid[0].size

    new_grid = []
    grid.each do |row|
        n = []
        row.each do |r|
            n << r
        end
        new_grid << n
    end

    grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
            new_grid[x][rows - y - 1] = c
        end
    end

    new_grid
end

MEMO = {}
def part_2(grid, i)
    return [MEMO[grid], i, true] if MEMO.key? grid

    orig_grid = []
    grid.each do |row|
        orig_grid << row.clone()
    end

    grid_rows = grid.size
    (0...4).each do |_|
        column_highest_blocker = grid[0].map{|_| -1}
        grid.each_with_index do |row, y|
            row.each_with_index do |c, x|
                case c
                when 'O'
                    resting_place = column_highest_blocker[x] + 1
                    column_highest_blocker[x] = resting_place
                    
                    grid[y][x] = '.'
                    grid[resting_place][x] = 'O'
                when '#'
                    column_highest_blocker[x] = y
                end
            end
        end

        grid = rotate_clockwise(grid)
    end

    # need to do the sum at the end so that we're considering the grid AFTER all the rounds of shuffling
    sum = 0 
    grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
            if c == 'O'
                sum += grid_rows - y
            end
        end
    end

    MEMO[orig_grid] = [grid, sum, i]
    [grid, sum, false]
end

def print_grid(grid)
    print '  '
    grid[0].each_with_index {|_, i| print i % 10}
    print "\n"
    grid.each_with_index do |row, y|
        print "#{y % 10} "
        row.each do |c|
            print c
        end
        print "\n"
    end
    print "\n"
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
grid, actual = part_1(grid)
# print_grid(grid)
raise "test error 1 #{actual} != 136" if actual != 136

# grid = parse(input)
# (0...3).each do |_|
#     n, sum = part_2(grid) 
#     print_grid(n)
#     grid = n
# end


input = File.read("input.txt")
grid = parse(input)
grid, actual = part_1(grid)
puts actual

MEMO.clear
grid = parse(input)
CYCLES =1000000000
(0...CYCLES).each do |i|
    grid, actual, found_cycle = part_2(grid, i)
    break if found_cycle
end

first_loop = actual
start_loop = grid[2]
remaining_cycles = CYCLES - start_loop - 1
cycle_length = first_loop - start_loop
cycle_index = remaining_cycles % cycle_length
target_i = start_loop + cycle_index
target =  MEMO.find{|_, (_,sum, i)| i == target_i}
puts target[1][1]
