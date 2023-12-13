def parse(input)
    input.split(/\n\n/)
        .map{|p| p.split(/\n/)}
        .map{|p| p.map{|row| row.split('')}}
end

def part_1(input)
    puzzles = parse(input)
    count = 0
    puzzles.each do |grid|
        # look for horizontal line reflection by moving through pairs of row indices
        horizontal_reflection_point = (0...grid.size).each_cons(2).find do |t_row, b_row|
            (0 ... (grid.size - b_row)).all? do |row_offset|
                next true if row_offset > t_row
                (0...grid[0].size).all? do |col|
                    grid[b_row + row_offset][col] == grid[t_row - row_offset][col]
                end
            end
        end
        if horizontal_reflection_point
            puts "found horizontal #{grid}"
            count += 100 * (horizontal_reflection_point[1])
            next
        end

        vertical_reflection_point = (0...grid[0].size).each_cons(2).find do |l_col, r_col|
            (0 ... (grid[0].size - r_col)).all? do |col_offset|
                next true if col_offset > l_col
                (0... grid.size).all? do |row|
                    puts "rows messed up? #{row} #{r_col + col_offset} #{l_col - col_offset}"
                    grid[row][r_col + col_offset] == grid[row][l_col - col_offset]
                end
            end
        end
        if vertical_reflection_point
            puts "found vertical #{grid}"
            count += vertical_reflection_point[1]
        end
    end
    count
end

def part_2(input)
end

input = <<END
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
END
actual = part_1(input)
raise "test error 1 #{actual} != 405" unless actual == 405

# input = <<END
# END

# raise "test error 2 #{actual} != " unless actual == 

input = File.read("input.txt")
puts part_1(input)
# puts part_2(input)