function parse_ranges(ranges::Vector{String})::Vector{Tuple{Int, Int}}
    map(ranges) do range
        s = split(range, '-')
        (parse(Int, s[1]), parse(Int, s[2]))
    end
end
# Merge overlapping intervals into one
# Input must sorted
function remove_overlap(fresh_ids)
    res::Vector{Tuple{Int, Int}} = []
    interval = fresh_ids[1]
    j = 2
    while j <= length(fresh_ids)
        if interval[2] >= fresh_ids[j][1]
            interval = (interval[1], max(interval[2], fresh_ids[j][2]))
        else
            push!(res, interval)
            interval = fresh_ids[j]
        end
        j+=1
    end
    push!(res, interval)
    res
end
lines = readlines("05/input")
fresh_str = lines[begin:findfirst(s -> s == "", lines)-1]
ids_str = lines[length(fresh_str)+2:end]
fresh_ids = parse_ranges(fresh_str)
sorted_fresh_ids = sort(fresh_ids, by = tup -> tup[1])

ids = parse.(Int, ids_str)
sorted_ids = sort(ids)


# ids and fresh_ids must be sorted
# fresh_ids must not have any overlap
function find_fresh(ids, fresh_ids)::Vector{Bool}
    i::Int = 1
    fresh = zeros(Bool, length(ids))
    for j in eachindex(ids)
        id = ids[j]
        # Seek the interval that could contain the id
        # Any intervals we skip cant apply to any other id due the sorted input
        while id > fresh_ids[i][2] 
            i += 1
            if i > length(fresh_ids)
                return fresh
            end
        end
        fresh[j] = id >= fresh_ids[i][1]
    end
    fresh
end
sum(find_fresh(sorted_ids, remove_overlap(sorted_fresh_ids)))

sum(map(remove_overlap(sorted_fresh_ids)) do tup
    tup[2] - tup[1] + 1
end)