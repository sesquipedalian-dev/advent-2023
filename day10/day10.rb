#    --A-- -

# N negative Y, S positive Y, E positive X, W negative X
#
N = [0, -1]
E = [1, 0]
W = [-1, 0]
S = [0, 1]

SYMBOL_TO_NEIGHBOR = {
    '|' => [N, S], 
    '-' => [E, W], 
    'L' => [N, E], 
    'J' => [N, W], 
    '7' => [W, S], 
    'F' => [E, S]
}

def parse(input)
    grid = input.split(/\n/).map{|l| l.split('')}

    start = nil
    grid.each_with_index do |row, y|
        row.each_with_index do |symbol, x|
            if symbol == 'S'
                start = [x, y]
                break
            end
        end
        break if start
    end

    [start, grid]
end

def calc_loop(start, grid)
    # based on the test inputs we have, only the 2 adjacent pipes to S
    # that lead in to S are part of the loop
    starting_neighbors = [N,S,E,W].map do |n_diff|
        x_coord = start[0]  + n_diff[0]
        y_coord = start[1] + n_diff[1]

        next nil if x_coord < 0 || x_coord >= grid[0].size || y_coord < 0 || y_coord >= grid.size

        sym = grid[y_coord][x_coord]
        sym_neighbors = SYMBOL_TO_NEIGHBOR[sym]

        next nil unless sym_neighbors

        found = sym_neighbors.any? do |n| 
            ((x_coord + n[0]) == start[0]) && ((y_coord + n[1]) == start[1])
        end
        [x_coord, y_coord, found]
    end.compact.filter {|t| t[2]} .map{|a| a.pop; a}

    # now, we navigate through the pipes in both directions, 
    # keeping track of nodes we've seen.  
    # if both directions hit the same destination, that's the farthest point
    # otherwise if they hit a coord already seen, then they've overlapped and it's current steps - 1
    from = [start, start]
    current = starting_neighbors
    seen = {start => true}
    starting_neighbors.each {|n| seen[n] = true}
    done = false
    while !done
        nexts = current.map.with_index do |(x, y), i|
            # figure out which neighbor we want
            sym = grid[y][x]
            sym_neighbors = SYMBOL_TO_NEIGHBOR[sym]
            next_direction = sym_neighbors.find {|n| !(((x + n[0]) == from[i][0]) && ((y + n[1]) == from[i][1]))}
            next_x = x + next_direction[0]
            next_y = y + next_direction[1]
            [next_x, next_y]
        end

        # if both directions are same, that target is the farthest
        done ||= nexts.uniq.size == 1

        # if either direction is already seen, the current i is farthest
        done ||= nexts.any? {|n| seen[n]}

        from = current
        current = nexts
        nexts.each { |n| seen[n] = true}
    end

    seen.keys
end

def part_1(input)
    start, grid = parse(input)
    coords_on_loop = calc_loop(start, grid)
    coords_on_loop.size / 2
end

def part_2(input)
    start, grid = parse(input)
    coords_on_loop = calc_loop(start, grid)

    # so this is a dynamic programming problem of a sort.
    # we want to build up a map of coords that can escape to the outside of the grid
    # these are not enclosed.
    # we can start on the boundaries of the grid and work in so that we can use those border
    # calculations to help the inner ones

end

input = <<END
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
END

actual = part_1(input)
raise "test error 1.1 #{actual} != 4" if actual != 4

input = <<END
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
END
actual = part_1(input)
raise "test error 1.2 #{actual} != 8" if actual != 8

input = File.read("input.txt")
# 6823
puts part_1(input)