using LinearAlgebra
function get_junctions_vec(f = "08/input")::Vector{Vector{Int}}
    ranges::Vector{Vector{Int}} = []
    for line::String in eachline(f)
        vec ::Vector{Int} = parse.(Int, split(line, ",", keepempty = false))
        push!(ranges, vec)
    end
    ranges
end
mx = reduce(vcat, transpose.(get_junctions_vec()))

"""Matrix of squared euclidian distance pairwise"""
function pairwise_distance(m)
    rows = size(m, 1)
    sum = zeros(Int, rows, rows)
    for dim in 1:size(m, 2)
        b = pairwise_diff(m[:,dim]).^2
        sum += b
    end
    sum
end
"""Given a vector, give a matrix where entry a, b is the vec[a] - vec[b]"""
function pairwise_diff(vec)
    mx = repeat(vec, 1, length(vec))
    mx .- vec'
end

"""Vector of tuples (a, b, c) where c is the distance between a and b """
function distances(mx)::Vector{Tuple{Int, Int, Int}}
    distances = pairwise_distance(mx)
    dist_vec::Vector{Tuple{Int, Int, Int}} = []
    for ind in CartesianIndices(distances)
        (a, b) = Tuple(ind)
        if a > b 
            push!(dist_vec, (a, b, distances[a, b]))
        end
    end
    dist_vec
end
function connect(mx, max_n = 1000)
    dists = sort(distances(mx), by = tup -> tup[3])
    circuit_nr = Int16.(1:size(mx, 1))
    connections::Vector{Tuple{Int, Int}} = []
    n = 1
    while n <= max_n && !allequal(circuit_nr)
        (a, b, _) = dists[n]
        # Set the whole circuit to the other number
        circuit_nr[circuit_nr[a] .== circuit_nr] .= circuit_nr[b]
        push!(connections, (a, b))
        n += 1
    end
    (circuit_nr, connections)
end
# Alternative, instead of sorting the distance once
# in each iteration find the min distance with a scan and set to a high value
# Much slower...
# function connect(mx, max_n = 1000)
#     distances = LinearAlgebra.LowerTriangular(pairwise_distance(mx))
#     MAX = typemax(typeof(distances[1, 1]))
#     # Make upper triangle and diagonal so large, they can not be the anwswer
#     distances = distances .+ (distances .== 0) .* MAX
#     circuit_nr = Int16.(1:size(mx, 1))
#     connections::Vector{Tuple{Int, Int}} = []
#     n = 1
#     while n <= max_n && !allequal(circuit_nr)
#         (a,b) = Tuple(argmin(distances))
#         distances[a, b] = MAX
#         # Set the whole circuit to the other number
#         circuit_nr[circuit_nr[a] .== circuit_nr] .= circuit_nr[b]
#         push!(connections, (a, b))
#         n += 1
#     end
#     (circuit_nr, connections)
# end

function mul_biggest_circuits(mx, n = 1000)
    (circuit_nr, _) = connect(mx, n)
    uniq_circs = unique(circuit_nr)
    count = zeros(Int, size(uniq_circs))
    for circ_i in eachindex(uniq_circs)
        count[circ_i] = sum(circuit_nr .== uniq_circs[circ_i])
    end
    prod(-sort(-count)[1:3])
end
# Part 1
println(mul_biggest_circuits(mx, 1000))

# Part 2
(_, conns) = connect(mx, typemax(Int))

println(prod(mx[[conns[end][1], conns[end][2]], 1]))