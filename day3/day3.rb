XLEFT = 0
XRIGHT = 1
Y = 2
NUMBER = 3

def parse(input)
    # it should look like:
    # {
    #     'parts' : [
    #         [xl, xr, y, number]
    #     ]
    #     'symbols': [
    #         [[x, y], symbol]
    #     ]
    # }
    output = {
        parts: [],
        symbols: []
    }
    x = 0
    y = 0
    input.split(/\n/).each do |line|
        line << '.' # make sure we terminate a number that ends the line
        x = 0
        running_num = nil
        line.chars.each do |c|
            if running_num
                unless c =~ /\d/
                    running_num[XRIGHT] = x - 1
                    output[:parts] << running_num
                    running_num = nil

                    if c != '.'
                        output[:symbols]  << [[x, y], c]
                    end
                else
                    running_num[NUMBER] << c
                end
            else
                if c =~ /\d/
                    running_num = [x, 0, y, c]
                elsif c != '.'
                    output[:symbols] << [[x, y], c]
                end
            end
            x += 1
        end
        y += 1
    end

    output
end

def adjacent?(part, symbol)
    xl = part[XLEFT] - 1
    xr = part[XRIGHT] + 1
    yb = part[Y] - 1
    yt = part[Y] + 1

    (x, y), _ = symbol
    xl <= x && x <= xr && yb <= y && y <= yt
end

def part_1(input)
    input = parse(input)

    # so each 'part number' occupies a bounding box on the grid: xl, xr, y, where xl < xr
    # a 'part number' is adjacent to a symbol if any symbol is within its bounding box, +/- 1 x and +/- 1 y

    input[:parts].inject(0) do |sum, part|
        adjacent = input[:symbols].inject(false) do |adjacent, symbol|
            adjacent || adjacent?(part, symbol)
        end

        sum + (adjacent ? part[NUMBER].to_i : 0)
    end
end

def part_2(input)
    input = parse(input)

    # find gears 'adjacent' to 2 part numbers
input[:symbols]
    .filter {|(_, sym)| sym == '*'}
    .inject(0) do |sum, symbol|
        adjacent_parts = input[:parts].filter{ |part| adjacent?(part, symbol)}
        next sum unless adjacent_parts.size == 2
        
        sum + (adjacent_parts[0][NUMBER].to_i * adjacent_parts[1][NUMBER].to_i)
    end
end

input = <<END
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
END
puts parse(input)
raise "test error 1 #{part_1(input)} != 4361" unless part_1(input) == 4361

input = <<END
..........................................389.314.................206......................449.523..................138.....................
.........+.....954......723..........................................*.............687.....*..........692..........*........................
121......992...............*.......%585....814............936.......102..#353.........*.....140.........*..434..301..................%..315.
.../....................877................*...523............489.................*....380.......174..263.@..............824......710.......
...........$..733*758.......435...656...483.....................*..%855........154.779.....674...............320+....+........373...........
........707......................................503.422...591.551......676............306...*....................220..........@..410..639..
END
raise "test error 1.5 #{part_1(input)} != 16063" unless part_1(input) == 16063

input = <<END
..123
....+
..45.
END
raise "test error 1.75 #{part_1(input)} != 168" unless part_1(input) == 168

input = <<END
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
END

raise "test error 2 #{part_2(input)} != 467835" unless part_2(input) == 467835

input = File.read("puzzle_input.txt")
puts part_1(input)
puts part_2(input)