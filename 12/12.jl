Shape = Vector{BitMatrix}

function create_variants(mx::BitMatrix)::Vector{BitMatrix}
    a = create_rotations(mx)
    b = create_rotations(mx')
    unique([a;b])
end

function create_rotations(mx)::Vector{BitMatrix}
    map(0:3) do i
        rotr90(mx, i)
    end
end

struct Tree
    presents::Vector{Int}
    size::Tuple{Int, Int}
end

function read_input(f = "12/input")::Tuple{Vector{Shape}, Vector{Tree}}
    shapes = []
    trees = []
    shape_parts = []
    reading_shape = false
    for line in eachline(f)
        if reading_shape
            if line == ""
                push!(shapes, make_shape(shape_parts))
                shape_parts = []
                reading_shape = false
            else
                push!(shape_parts, line)
            end
        end
        if line != "" && line[end] == ':'
            reading_shape = true
        elseif 'x' in line
            push!(trees, make_tree(line))
        end
    end
    shapes, trees
end

function make_shape(parts)::Shape
    mx = falses(length(parts), length(parts[1]))
    for line_i in eachindex(parts)
        for j in eachindex(parts[line_i])
            mx[line_i, j] = parts[line_i][j] == '#'
        end
    end
    create_variants(mx)
end
function make_tree(tree)
    parts = split(tree, ":")
    size = parse.(Int, split(parts[1], "x"))
    presents = parse.(Int, split(parts[2], " ", keepempty = false))
    Tree(presents, Tuple(size))
end

function fits(mx, i, j, mx_other)::Bool
    (x, y) = Tuple(size(mx))
    i + size(mx_other, 1) - 1 <= x && j + size(mx_other, 2) - 1 <= y
end

function get_ranges(i, j, mx_other)
    range_x = i:i+size(mx_other, 1) - 1
    range_y = j:j+size(mx_other, 1) - 1
    (range_x, range_y)
end

function conflicts(mx, i, j, mx_other)::Bool
    range_x,range_y = get_ranges(i, j, mx_other)
    any(mx[range_x, range_y] .& mx_other)
end

function place!(mx, i, j, mx_other)
    range_x, range_y = get_ranges(i, j, mx_other)
    mx[range_x, range_y] .= mx[range_x, range_y] .| mx_other
    mx
end

function clear!(mx, i, j, mx_other)
    range_x, range_y = get_ranges(i, j, mx_other)
    mx[range_x, range_y] .= mx[range_x, range_y] .& .!mx_other
    mx
end

function solve(tree::Tree, shapes::Vector{Shape})
    if !check_tree_vol(tree, shapes)
        return false
    end
    place_presents(falses(tree.size), copy(tree.presents), shapes)
end

function place_presents(mx::BitMatrix, presents::Vector{Int}, shapes::Vector{Shape})::Bool
    present = findfirst(presents .> 0)
    if isnothing(present)
        return true
    end
    presents[present] -= 1
    for variant in shapes[present]
        for i in axes(mx, 1)
            for j in axes(mx, 2)
                if fits(mx, i, j, variant) && !conflicts(mx, i, j, variant)
                    mx_placed = place!(mx, i, j, variant)
                    if place_presents(mx_placed, presents, shapes)
                        return true
                    end
                    clear!(mx, i, j, variant)
                end
            end
        end
    end
    presents[present] += 1
    return false
end

vol(shape) = sum(shape[1])

function vol_check(mx, presents, shapes::Vector{Shape})
    vols = vol.(shapes)
    needed_vol = sum(presents .* vols)
    sum(.!mx) >= needed_vol
end

function check_tree_vol(tree::Tree, shapes)
    vols = vol.(shapes)
    needed_vol = sum(tree.presents .* vols)
    prod(tree.size) >= needed_vol
end

# Example
# ex_shapes, tree_ex = read_input("12/example_input")
# solve(tree_ex[3], ex_shapes)

(shapes, trees) = read_input()

# Actually for THIS input it's enough to do the volume check.
# This is only reasonable fast because all the infeasible 
# trees also dont pass the volume check.
# The feasible trees are solved quickly
count = sum(map(trees) do tree
    solve(tree, shapes)
end)

println(count)