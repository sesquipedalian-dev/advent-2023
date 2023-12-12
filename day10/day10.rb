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

    puts "calculated start: #{start} #{starting_neighbors}"
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

    seen
end

def part_1(input)
    start, grid = parse(input)
    coords_on_loop = calc_loop(start, grid)
    coords_on_loop.keys.size / 2
end

ESCAPABLE = []
TEMP_ESCAPABLE = []
GRID = []
ON_STACK = {}

def part_2(input)
    start, grid = parse(input)
    coords_on_loop = calc_loop(start, grid)

    # walk the grid and insert additional rows and columns that are a different symbol 
    # that doesn't count as an interior space, but does allow you to traverse for the 
    # purpose of exiting.  
    # For each new spot, when adding rows check if any pipes at the rows you're inserting between were connected, and replace the '&' with a connecting pipe
    # similarly when adding columns check if pipes in the adjacent columns were previously connected, and replace the '&' with a connecting pipe
    #
    # insert additional columns
    orig_grid_rows = grid.size
    orig_grid_columns = grid[0].size
    (0...orig_grid_rows).each_cons(2).each_with_index do |(y1, y2), i|
        new_row = []
        orig_y1 = (i*2)
        orig_y2 = orig_y1 + 1

        (0...orig_grid_columns).each do |x|
            orig_top_symbol = grid[orig_y1][x]
            top_can_connect = %w[ | 7 F S].include? orig_top_symbol

            orig_bottom_symbol = grid[orig_y2][x]
            bottom_can_connect = %w[ | L J S].include? orig_bottom_symbol

            # should exclude 
            if top_can_connect && bottom_can_connect && coords_on_loop.key?([x, i])
                new_row << '|'
            else
                new_row << '&'
            end
        end

        grid.insert(orig_y2, new_row)
    end

    # insert additional rows
    orig_grid_columns = grid[0].size
    orig_grid_rows = grid.size
    (0...orig_grid_columns).each_cons(2).each_with_index do |(x1, x2), i|
        orig_x1 = (i*2)
        orig_x2 = orig_x1 + 1

        (0...orig_grid_rows).each do |y|
            orig_left_symbol = grid[y][orig_x1]
            left_can_connect = %w[ - F L S].include? orig_left_symbol

            orig_right_symbol = grid[y][orig_x2]
            right_can_connect = %w[ - 7 J S].include? orig_right_symbol

            new_sym = if left_can_connect && right_can_connect && coords_on_loop.key?([i, y/2])
                '-'
            else
                '&'
            end

            grid[y].insert(orig_x2, new_sym)
        end
    end

    # recalculate start
    start = [start[0] * 2, start[1] * 2]

    grid.each do |row|
        row.each do |c|
            print c
        end
        print "\n"
    end

    GRID.clear
    grid.each do |row|
        grid_row = [] + row
        GRID << grid_row
    end

    coords_on_loop = calc_loop(start, grid)

    # so this is a dynamic programming problem of a sort.
    # we want to build up a map of coords that can escape to the outside of the grid
    # these are not enclosed.
    # we can start on the boundaries of the grid and work in so that we can use those border
    # calculations to help the inner ones

    # initialize escapable to 'undefined' for all grid points
    ESCAPABLE.clear
    TEMP_ESCAPABLE.clear
    grid.each_with_index do |row, _|
        e_row = []
        t_row = []
        row.each_with_index do |_, _|
            e_row << nil
            t_row << nil
        end
        ESCAPABLE << e_row
        TEMP_ESCAPABLE << t_row
    end

    ON_STACK.clear
    count = 0
    grid.each_with_index do |row, y|
        print "\n"
        row.each_with_index do |_, x|
            if coords_on_loop.key? [x, y]
                print grid[y][x]
                next
            end

            # do not count entries that were inserted to account for 'squeezing between the pipes'
            # these are either on an odd row or column number
            is_fake = (y%2 == 1) || (x%2 ==1)

            # copy resolved ESCAPABLE array into TEMP
            TEMP_ESCAPABLE.clear
            ESCAPABLE.each do |row|
                t_row = []
                row.each do |i|
                    t_row << i
                end
                TEMP_ESCAPABLE << t_row
            end

            puts "recur start for #{x} #{y}"
            escapable = part_2_recur(x, y, coords_on_loop ) #, log = ((y == 166) && (x==26)))
            ESCAPABLE[y][x] = escapable
            print (is_fake ? escapable ? 'E' : '&' : escapable ? "T" : "Q")
            if !escapable && !is_fake
                count += 1  
            end
        end
    end
    print "\n"

    count
end

def part_2_recur(x, y, coords_on_loop, log=true)
    puts "part_2_recur enter #{x} #{y} #{ESCAPABLE[y][x]}" if log
    # return memoized value if available,
    memoed = TEMP_ESCAPABLE[y][x]
    return memoed if memoed != nil

    # return false if part of the pipe loop
    result = if coords_on_loop.key? [x, y]
        false
    else 
        ON_STACK[[x,y]] = true
        # check if any neighbors are escapable, if so we are too
        # if not, we are not escapable
        [N,S,E,W].any? do |n| 
            new_x = x + n[0]
            new_y = y + n[1]
           
            puts "skipping due to on stack? #{new_x} #{new_y} #{ON_STACK[[new_x, new_y]]}" if log
            next false if ON_STACK[[new_x, new_y]]

            out_of_bounds = new_x < 0 || new_x >= GRID[0].size || new_y < 0 || new_y >= GRID.size
            puts "out of bounds? #{out_of_bounds}" if log
            next true if out_of_bounds

            puts "recursing from #{x} #{y} to #{new_x} #{new_y}" if log
            part_2_recur(new_x, new_y, coords_on_loop, log)
        end
    end 

    # memoize result and return
    ON_STACK[[x,y]] = false
    puts "escapable result #{x} #{y} #{result}" if log
    TEMP_ESCAPABLE[y][x] = result
    result
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

input = <<END
..........
.S------7.
.|F----7|.
.||....||.
.||....||.
.|L-7F-J|.
.|..||..|.
.L--JL--J.
..........
END
# actual = part_2(input)
# raise "test error 2.1 #{actual} != 4" if actual != 4

input = <<END
F---7..
|S-7|..
||.||..
||.LJ..
|L---7.
L----J.
END
# actual = part_2(input)
# raise "test error 2.2 #{actual} != 0" if actual != 0

input = <<END
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
END
# actual = part_2(input)
# raise "test error 2.3 #{actual} != 8" if actual != 8

input = <<END
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
END
# actual = part_2(input)
# raise "test error 2.4 #{actual} != 10" if actual != 10

input = <<END
F---7
|F-7|
LJ.||
F--J|
L---S
END
# actual = part_2(input)
# raise "test error 2.5 #{actual} != 0" if actual != 0

input = <<END
-F---S.
F|F-7|.
J||L||.
|||7||.
7||-||.
-LJ|||.
F---JL7
|.....|
L-----J
END
# actual = part_2(input)
# raise "test error 2.6 #{actual} != 5" if actual != 5

input = File.read("input.txt")
# 6823
puts part_1(input)
# 587 is too high
# 527 is too high
puts part_2(input)
