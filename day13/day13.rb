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
            count += 100 * (horizontal_reflection_point[1])
            next
        end

        vertical_reflection_point = (0...grid[0].size).each_cons(2).find do |l_col, r_col|
            (0 ... (grid[0].size - r_col)).all? do |col_offset|
                next true if col_offset > l_col
                (0... grid.size).all? do |row|
                    grid[row][r_col + col_offset] == grid[row][l_col - col_offset]
                end
            end
        end
        if vertical_reflection_point
            count += vertical_reflection_point[1]
        end
    end
    count
end

def part_2(input)
    puzzles = parse(input)
    count = 0
    puzzles.each do |grid|
        # look for horizontal line reflection by moving through pairs of row indices
        horizontal_reflection_point = (0...grid.size).each_cons(2).find do |t_row, b_row|
            error_rows = (0 ... (grid.size - b_row)).map do |row_offset|
                next [] if row_offset > t_row
                (0...grid[0].size).filter do |col|
                    grid[b_row + row_offset][col] != grid[t_row - row_offset][col]
                end
            end

            error_rows.find{|r| r.size == 1} && error_rows.filter{|r| r.size != 1}.all? {|r| r.size == 0}
        end
        if horizontal_reflection_point
            count += 100 * (horizontal_reflection_point[1])
        end

        vertical_reflection_point = (0...grid[0].size).each_cons(2).find do |l_col, r_col|
            error_cols = (0 ... (grid[0].size - r_col)).map do |col_offset|
                next [] if col_offset > l_col
                (0... grid.size).filter do |row|
                    grid[row][r_col + col_offset] != grid[row][l_col - col_offset]
                end
            end
            error_cols.find{|r| r.size == 1} && error_cols.filter{|r| r.size != 1}.all? {|r| r.size == 0}
        end
        if vertical_reflection_point
            count += vertical_reflection_point[1]
        end
    end
    count
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

actual = part_2(input)
raise "test error 2 #{actual} != 400" unless actual == 400

input = File.read("input.txt")
puts part_1(input)
puts part_2(input)