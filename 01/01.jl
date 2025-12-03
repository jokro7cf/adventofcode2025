nums = zeros(Int, 0)
for line in eachline("01/input")
    sign = line[1] == 'R' ? 1 : -1
    num = parse(Int, line[2:end])
    push!(nums, sign * num)
end
# First part
println(sum((cumsum([50; nums]) .% 100 ) .== 0))

function add_to_dial(dial::Int, num::Int)
    dial_new = dial
    counts_to_add = 0
    while num != 0
        turn = max(-100, min(100, num))
        num -= turn
        dial_new += turn
        dial_mod = (dial_new + 100) % 100
        to_add = dial != 0 ? dial_mod != dial_new || dial_new == 0 : abs(turn) == 100
        println("$dial + $turn = $dial_mod with $to_add count")
        counts_to_add += to_add
        dial_new = dial_mod
    end
    return dial_new, counts_to_add
end
# Example from page:


    # The dial starts by pointing at 50.
    # The dial is rotated L68 to point at 82; during this rotation, it points at 0 once.
    # The dial is rotated L30 to point at 52.
    # The dial is rotated R48 to point at 0.
    # The dial is rotated L5 to point at 95.
    # The dial is rotated R60 to point at 55; during this rotation, it points at 0 once.
    # The dial is rotated L55 to point at 0.
    # The dial is rotated L1 to point at 99.
    # The dial is rotated L99 to point at 0.
    # The dial is rotated R14 to point at 14.
    # The dial is rotated L82 to point at 32; during this rotation, it points at 0 once.

example_nums = [-68, -30, 48, -5, 60, -55, -1, -99, 14, -82]
dial = 50
count = 0
for ex_num in example_nums
    dial, counts_to_add = add_to_dial(dial, ex_num)
    count += counts_to_add
end
println("Example dial ", dial)
println("Example count ", count)

dials = [];dial::Int = 50; count::Int = 0; for num in nums
    push!(dials, dial)
    if num == 0
        println("num is zero")
    end
    dial, counts_to_add = add_to_dial(dial, num)
    count += counts_to_add
end
println("dial ", dial)
println(count)

dials[1:1000]
dials_true = (((cumsum([50; nums]) .% 100) .+ 100) .% 100)
for i in 1:length(dials)
    if dials[i] != dials_true[i]
        println(i)
        break
    end
end