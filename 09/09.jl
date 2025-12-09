function get_junctions_vec(f = "09/input")::Vector{Vector{Int}}
    ranges::Vector{Vector{Int}} = []
    for line::String in eachline(f)
        vec ::Vector{Int} = parse.(Int, split(line, ",", keepempty = false))
        push!(ranges, vec)
    end
    ranges
end
mx = reduce(vcat, transpose.(get_junctions_vec()))
mx_ex = reduce(vcat, transpose.(get_junctions_vec("09/example_input")))
function pairwise_distance(m)
    rows = size(m, 1)
    area = ones(Int, rows, rows)
    for dim in 1:size(m, 2)
        b = abs.(pairwise_diff(m[:,dim])) .+1
        area *= b
    end
    area
end
"""Given a vector, give a matrix where entry a, b is the vec[a] - vec[b]"""
function pairwise_diff(vec)
    mx = repeat(vec, 1, length(vec))
    mx .- vec'
end
function area(mx, a, b)::Int
    prod(abs.(mx[a, :] - mx[b,:]) .+1)
end

"""Simply test all possible rectangles"""
function get_max_area_part1(mx)
    max_area = 0
    for row in eachrow(mx)
        for row2 in eachrow(mx)
            max_area = max(max_area, prod(abs.(row - row2) .+1))
        end
    end
    max_area
end
println("part one")
println(get_max_area_part1(mx))

# Part 2


in_range_excl(x, r) = r[1] < x && x < r[2]

point_in_rec(pos, rec_x, rec_y) = in_range_excl(pos[1], rec_x) && in_range_excl(pos[2], rec_y)


function edge_in_rec(a, b, rec_x, rec_y)
    if a[1] > b[1] || a[2] > b[2]
        b, a = a, b
    end

    # Is one the endpoints inside the rectangle?
    if point_in_rec(a, rec_x, rec_y) || point_in_rec(b, rec_x, rec_y)
        return true
    end
    if a[1] == b[1]
        # vertical, are they on opposite sites?
        if in_range_excl(a[1], rec_x)
            if a[2] <= rec_y[1] && b[2] >= rec_y[2]
                return true
            end
        end
    else
        # horizontal, are they on opposite sites?
        if in_range_excl(a[2], rec_y)
            if a[1] <= rec_x[1] && b[1] >= rec_x[2]
                return true
            end
        end
    end
    return false
end

function get_rectangle(mx, a, b)
    rec_x = (minimum(mx[[a,b], 1]), maximum(mx[[a,b], 1]))
    rec_y = (minimum(mx[[a,b], 2]), maximum(mx[[a,b], 2]))
    rec_x, rec_y
end

"""Test whether no edge crosses the rectangle"""
function no_edge_inside(mx, a, b)::Bool
    prev = size(mx, 1)
    rec_x, rec_y, = get_rectangle(mx, a, b)
    for cur in 1:size(mx, 1)
        if edge_in_rec(mx[prev, :], mx[cur, :], rec_x, rec_y)
            return false
        end
        prev = cur
    end 
    return true
end

"""area = 0 for invalid rectangles and their area otherwise"""
function valid_rec(mx, a, b)::Int
    if no_edge_inside(mx, a, b)
        area(mx, a, b)
    else
        0
    end
end
dists = pairwise_distance(mx)

function get_max_area(mx)
    combinations::Vector{Tuple{Int, Int}} = []
    for row in 1:size(mx, 1)
        for row2 in 1:size(mx, 1)
            if row < row2
                push!(combinations, (row, row2))
            end
        end
    end
    res = zeros(Int, size(combinations))
    for i in eachindex(combinations)
        res[i] = valid_rec(mx, combinations[i][1], combinations[i][2])
    end
    ind = argmax(res)
    (res[ind], combinations[ind])
end
# example
@show get_max_area(mx_ex)
# real input
@show get_max_area(mx)