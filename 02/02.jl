function get_ranges_str()
    ranges::Vector{String} = []
    for line::String in eachline("02/input")
        append!(ranges, split(line, ",", keepempty = false))
    end
    ranges
end
function parse_ranges(ranges::Vector{String})::Vector{Tuple{Int, Int}}
    map(ranges) do range
        s = split(range, '-')
        (parse(Int, s[1]), parse(Int, s[2]))
    end
end
function list_numbers(tup)::Vector{Int}
    tup[1]:tup[2]
end
function check_mirrored(s::String)::Bool
    if length(s) % 2 == 0
        mid::Int = length(s) / 2
        first = s[begin:mid]
        last = s[mid+1:end]
        first == last
    else
        false
    end
end


ranges = get_ranges_str() |> parse_ranges
nums = collect(Iterators.flatten(list_numbers.(ranges)))
println("Part 1")
println(sum(nums[check_mirrored.(string.(nums))]))

function check_repeated(s::String)::Bool
    function check_base(i)::Bool
        base = s[1:i]
        for k in (i+1):i:length(s)
            portion = s[k:(k+i - 1)]
            if portion != base
                return false
            end
        end
        return true
    end
    for i::Int in 1:floor(length(s) / 2)
        if !(ceil(length(s) / i) == length(s) / i)
            continue
        end
        if check_base(i)
            return true
        end
    end
    false
end
println("Part 2")
println(sum(nums[check_repeated.(string.(nums))]))