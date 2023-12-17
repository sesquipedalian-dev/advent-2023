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

                # puts "calcing cost from #{target} to #{dy}/#{dx}"
                new_c = case new_d
                when RIGHT
                    ((target[1] + 1)..dx).map {|ddx| grid[dy][ddx]}.sum
                when LEFT
                    (dx..target[1]).map {|ddx| grid[dy][ddx]}.sum
                when DOWN
                    ((target[0] + 1)..dy).map do |ddy| 
                        # puts "what what #{ddy}/#{dx} #{grid[ddy][dx]} #{grid}"
                        grid[ddy][dx]
                    end.sum
                when UP
                    (dy..target[0]).map {|ddy| grid[ddy][dx]}.sum
                end

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

def part_1(grid, verts)
    # Djikstra's https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
    dist = {}
    prev = {}
    visited = {}
    verts.each {|v| dist[v.key] = 0}
    queue = verts
    seen = {}
    while !queue.empty?
        queue.sort! {|v| dist[v.key] || (2**16) }
        u = queue.shift
        # puts "Djisktra iter #{u}"
        seen[u.key] = true


        break if u.target[0] == (grid.size - 1) && u.target[1] == (grid[0].size - 1)

        u.neighbors(grid).sort_by{|n| -n.s}.each do |v|
            next if seen[v.key]

            queue << v
            alt = dist[u.key] + v.c
            if alt < (dist[v.key] || (2**16))
                dist[v.key] = alt
                prev[v.key] = u.key
            end
        end
    end

    path_to_end = prev.find do |k, v|
        k[0] + (k[2][0] * k[3]) == (grid.size - 1) &&
        k[1] + (k[2][1] * k[3]) == (grid[0].size - 1)
    end[0]

    cost = 0
    while path_to_end != nil
        cost += dist[path_to_end]
        path_to_end = prev[path_to_end]
    end

    cost
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

# 0123456789012

# 0 2413432311323
# 1 3215453535623
# 2 3255245654254
# 3 3446585845452
# 4 4546657867536
# 5 1438598798454
# 6 4457876987766
# 7 3637877979653
# 8 4654967986887
# 9 4564679986453
# 0 1224686865563
# 1 2546548887735
# 2 4322674655533

grid, verts = parse(input)
puts grid.size, grid[0].size
puts verts
puts "**********************"
puts verts[0].neighbors(grid)
puts "**********************"
puts verts[1].neighbors(grid)
puts "**********************"
actual = part_1(grid, verts)
raise "test error 1 #{actual} != 102" unless actual == 102

# OK, now we just gotta djikstra until we get to max_rows max_cols

# actual = part_2(input)
# raise "test error 2 #{actual} != 51" unless actual == 51



input = File.read("input.txt")
# puts part_1(input)
# puts part_2(input)
