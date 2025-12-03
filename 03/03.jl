input = readlines("03/input")

findfirstmax(x)::Int = findfirst(maximum(x), x)

# First part

function get_largest(line::String)::Vector{Char}
    first_max = findfirstmax(line[begin:end-1])
    second_max = findfirstmax(line[first_max+1:end])

    [line[first_max], line[first_max+1:end][second_max]]
end

tuple_int(vec)::Int = parse(Int, String(vec))

sum(tuple_int.(get_largest.(input)))


# Second part
"""
Maximizes the banks output by choosing c batteries. c = 2 for the first part of the puzzle, c = 12 for the second.

This is solved recursively.
"""
function get_largest_generic(line::String, c::Int)::Vector{Char}
    if c > 1
        first_max = findfirstmax(line[begin:end-(c-1)])
        [line[first_max]; get_largest_generic(line[first_max+1:end], c - 1)]
    else
        [maximum(line)]
    end
end
sum(tuple_int.(get_largest_generic.(input, 12)))