def parse(input)
    grid = input.split(/\n/)
        .map{|l| l.split('').map(&:to_i)}

    # initialize first Verts with one starting / ending at top left, going:
    # RIGHT - should generate DOWN neighbors
    # DOWN - should generate RIGHT
    verts = [
        Vert.new(0, 0, RIGHT, 0, 0),
        Vert.new(0, 0, DOWN, 0, 0)
    ]

    [grid, verts]
end

RIGHT = [0, 1]
LEFT = [0, -1]
UP = [-1, 0]
DOWN = [1, 0]

def opposite(d)
    case d
    when RIGHT
        LEFT
    when LEFT
        RIGHT
    when UP
        DOWN
    when DOWN
        UP
    end
end

class Vert
    attr_accessor :y, :x, :d, :s, :c
    def initialize(y, x, d, s, c)
        @y = y
        @x = x
        @d = d
        @s = s
        @c = c
    end

    def to_s
        "#{y}/#{x} moving #{d} #{s} steps costs #{c}"
    end

    def neighbors(grid)
        [RIGHT, LEFT, UP, DOWN].filter{|d| d != @d && d != opposite(@d)}.map do |new_d|
            (1..3).map do |new_s|
                dy = target[0] + (new_d[0] * new_s)
                dx = target[1] + (new_d[1] * new_s)

                next nil unless in_bounds(grid, dy, dx)

                new_c = [RIGHT, LEFT].include?(new_d) ?
                    ((target[1] + 1)..dx).map {|ddx| grid[dy][ddx]}.sum :
                    ((target[0] + 1)..dy).map {|ddy| grid[ddy][dx]}.sum
                Vert.new(target[0], target[1], new_d, new_s, new_c)
            end
        end.flatten.compact
    end

    def target
        dy = @y + (@d[0] * @s)
        dx = @x + (@d[1] * @s)
        [dy, dx]
    end

    def key
        [@y, @x, @d, @s]
    end
end

def in_bounds(grid, y, x)
    0 <= y && y < grid.size && 0 <= x && x < grid[0].size
end

def part_1(input)
end


def part_2(input)
end

input = <<END
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
END

grid, verts = parse(input)
puts verts
puts "**********************"
puts verts[0].neighbors(grid)
puts "**********************"
puts verts[1].neighbors(grid)
puts "**********************"
actual = part_1(input)
raise "test error 1 #{actual} != 102" unless actual == 102

# OK, now we just gotta djikstra until we get to max_rows max_cols

# actual = part_2(input)
# raise "test error 2 #{actual} != 51" unless actual == 51



input = File.read("input.txt")
puts part_1(input)
# puts part_2(input)
