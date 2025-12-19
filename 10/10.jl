using DataStructures, JuMP, Cbc
import Memoization, Combinatorics
struct Machine
    lights::BitVector
    buttons::Vector{Vector{Int16}}
    joltage::Vector{Int16}
end

function read_input(f = "10/input")::Vector{Machine}
    vec::Vector{Machine} = []
    for line in eachline(f)
        push!(vec, parse_machine(line))
    end
    vec
end

function parse_lights(light_str::AbstractString)::BitVector
    lights = falses(length(light_str))
    for i in eachindex(light_str)
        lights[i] = light_str[i] == '#'
    end
    lights
end

function parse_machine(line::AbstractString)::Machine
    lights = Nothing
    buttons::Vector{Vector{Int8}} = []
    joltage = Nothing
    for comp in eachsplit(line)
        if comp[1] == '['
            lights = parse_lights(comp[2:end-1])
        elseif comp[1] == '('
            # +1 so the buttons are valid indices
            push!(buttons, 1 .+ parse.(Int16, split(comp[2:end-1], ',')))
        elseif comp[1] == '{'
            joltage = parse.(Int16, split(comp[2:end-1], ','))
        else
            error("unknown input $comp in line $line")
        end
    end
    Machine(lights, buttons, joltage)
end

machines = read_input()

LightState = Tuple{BitVector, Int}
# Breadth first traversal, simple and slow but not too slow
function solve_lights(machine::Machine)::Int
    target_lights = machine.lights
    stack = Deque{LightState}()
    push!(stack, (falses(length(target_lights)), 0))
    while true
        (lights, button_presses) = popfirst!(stack)
        for button in machine.buttons
            new_lights = copy(lights)
            new_lights[button] = .!new_lights[button]
            if new_lights == target_lights
                return button_presses + 1
            end
            push!(stack, (new_lights, button_presses + 1))
        end
        yield()
    end
end

# ~ 80 secs. Could be sped up like part two
@time sum(solve_lights.(machines))

# Part 2 solved with integer linear programming 

"""Solve using integer linear programming"""
function solve_joltage_milp(machine::Machine)
    target_jolt = machine.joltage
    # constrain matrix
    # each row is for one joltage input
    # each col is one of the buttons
    mx = falses(length(target_jolt), length(machine.buttons))
    for button_i in eachindex(machine.buttons)
        mx[machine.buttons[button_i], button_i] .= 1
    end
    model = Model(Cbc.Optimizer)
    set_attribute(model, "logLevel", 0)
    @variable(model, x[1:length(machine.buttons)] >= 0, Int)
    for jolt_i in eachindex(target_jolt)
        @constraint(model, sum(mx[jolt_i, :] .* x) == target_jolt[jolt_i])
    end
    @objective(model, Min, sum(x))
    #println(model)
    optimize!(model)
    assert_is_solved_and_feasible(model)
    #solution_summary(model)
    #@show value.(x)
    sum(value.(x))
end

# 0.2 sec
@time sum(solve_joltage_milp.(machines))


# Solution from https://www.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
function binary_buttons_matrix(machine::Machine)::Tuple{AbstractMatrix{Int16}, Vector{Int16}}
    button_presses::Vector{Int16} = zeros(2^length(machine.buttons))
    results = zeros(Int16, 2^length(machine.buttons), length(machine.joltage))
    for (i, buttons) in Iterators.enumerate(Combinatorics.powerset(1:length(machine.buttons)))
        button_presses[i] = length(buttons)
        for button in machine.buttons[buttons]
            results[i, button] .+= 1
        end
    end
    return (results, button_presses)
end

# If the target joltage contains uneven values, they must have come from 
# one of the combinations of pressing each button 0 or 1 times
# We can subtract that, div by 2 (all are even) and recurse
function solve_joltage_rec(machine::Machine)::Int16
    effects, counts = binary_buttons_matrix(machine)
    Memoization.@memoize Dict function find_min_presses_inner(target)::Int16
        @assert length(target) == size(effects, 2)
        if all(target .== 0) 
            return 0
        end
        min_counts = typemax(Int16)
        results = target' .- effects
        valid = all((results .% 2 .== 0) .& (results .>= 0); dims = 2)[:, 1]
        for ind in findall(valid)
            min_counts = min(min_counts, counts[ind] + 2 * find_min_presses_inner(results[ind, :] .÷ 2))
        end
        return min_counts
    end
    find_min_presses_inner(machine.joltage)
end
# ~1.5 sec
@time sum(solve_joltage_rec.(machines))

JoltageState = Tuple{Vector{Int16}, Int}
"""Breadth first traversal again, but this time it's too slow"""
function solve_joltage_bft(machine::Machine)::Int
    target_jolt = machine.joltage
    stack = Deque{JoltageState}()
    push!(stack, (zeros(length(target_jolt)), 0))
    while true
        (jolt, button_presses) = popfirst!(stack)
        for button in machine.buttons
            new_jolt = copy(jolt)
            new_jolt[button] = new_jolt[button] .+ 1
            if new_jolt == target_jolt
                return button_presses + 1
            end
            # Check if it's still reachable

            if !any(new_jolt > target_jolt) 
                push!(stack, (new_jolt, button_presses + 1))
            end
        end
    end
end
# Too slow
# sum(solve_joltage_bft.(machines))