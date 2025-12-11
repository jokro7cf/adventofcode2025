function read_input(f = "11/input")
    nodes = Dict{String, Vector{String}}()
    for line in eachline(f)
        names = split(line)
        nodes[names[1][1:end-1]] = names[begin + 1:end]
    end
    nodes
end
nodes = read_input()

# This works only with no loops
function count_paths(nodes, start = "you", target = "out")::Int
    # Important to return 0, as we cant go further ...
    # If you return 1 you get wrong results 🫠
    path_count = Dict{String, Int}("out" => 0)
    path_count[target] = 1
    function trace(node_name::String)::Int
        get!(path_count, node_name) do
            sum(trace.(nodes[node_name]))
        end
    end
    trace(start)
end

# Part1
count_paths(nodes, "you", "out")
# Part 2
first_variant = count_paths(nodes, "svr", "fft") * count_paths(nodes, "fft", "dac") * count_paths(nodes, "dac", "out")
second_variant = count_paths(nodes, "svr", "dac") * count_paths(nodes, "dac", "fft") * count_paths(nodes, "fft", "out")
first_variant + second_variant