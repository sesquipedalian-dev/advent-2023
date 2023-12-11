def parse(input)
    input.split(/\n/).map do |line|
        line.split('')
    end
end

def part_1(input)
    grid = parse(input)

    # double empty rows
    grid_columns = grid[0].size
    empty_indices = grid.map.with_index{|r, i| [r,i]}
        .filter {|r, _| !r.include?('#')}
        .map{|_,i| i}
    empty_indices.each_with_index do |grid_index, num_already_added|
        grid.insert(grid_index + num_already_added, (0...grid_columns).map{|_| '.'})
    end

    # double empty columns
    grid_rows = grid.size
    grid_columns = grid[0].size
    empty_indices = (0...grid_columns)
        .filter{|column| !(0...grid_rows).any?{|row| grid[row][column] == '#'}}
    empty_indices.each_with_index do |column, i|
        (0...grid_rows).each do |row|
            grid[row].insert(column + i, '.')
        end
    end

    # find indices of 'galaxies'
    galaxies = []
    grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
            if c == '#'
                galaxies << [x,y]
            end
        end
    end

    # match them pairwise, get manhattan distance, and sum
    galaxies.combination(2).map do |lhs, rhs|
        (lhs[0] - rhs[0]).abs + (lhs[1] - rhs[1]).abs
    end.sum
end


def part_2(input, duplication_factor)
    grid = parse(input)

    grid_rows = grid.size
    grid_columns = grid[0].size
    
    # note empty rows
    empty_rows = grid.map.with_index{|r, i| [r,i]}
        .filter {|r, _| !r.include?('#')}
        .map{|_,i| i}


    # double empty columns
    empty_columns = (0...grid_columns)
        .filter{|column| !(0...grid_rows).any?{|row| grid[row][column] == '#'}}

    # find indices of 'galaxies'
    galaxies = []
    grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
            if c == '#'
                galaxies << [x,y]
            end
        end
    end

    # match them pairwise, get manhattan distance, and sum
    galaxies.combination(2).map do |lhs, rhs|
        # find any empty rows / columns in between the two ranges, each of these adds 1000000 to the mahattan distance
        sorted_row = [lhs[1], rhs[1]].sort
        empty_rows_adjust = (duplication_factor - 1) * ((sorted_row[0])...sorted_row[1]).count {|r| empty_rows.include? r}

        sorted_column = [lhs[0], rhs[0]].sort
        empty_cols_adjust = (duplication_factor - 1) * ((sorted_column[0])...sorted_column[1]).count { |c| empty_columns.include? c}
        
        a = (lhs[0] - rhs[0]).abs
        b = (lhs[1] - rhs[1]).abs 
        c = empty_rows_adjust
        d = empty_cols_adjust
        [a,b,c,d]
    end.flatten.sum
end

input = <<END
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
END
actual = part_1(input)
raise "test 1.0 #{actual} != 374" if actual != 374

actual = part_2(input, 10)
raise "test 2.0 #{actual} != 1030" if actual != 1030

actual = part_2(input, 100)
raise "test 2.1 #{actual} != 8410" if actual != 8410


input = File.read("input.txt")
puts part_1(input)
puts part_2(input, 1000000)