using GLPK
using JuMP

function calcualte_cost(x::Vector{Tuple{Int,Int}}, C::Matrix{Int})
    cost = 0
    for e in x
        (j, m) = e
        cost += C[j, m]
    end
    return cost
end

function general_assignment(J::Vector{Int}, M::Vector{Int}, M_prim::Vector{Int}, P::Matrix{Int}, C::Matrix{Int}, T::Vector{Int}, y::Matrix{Bool})
    model = Model(GLPK.Optimizer)

    @variable(model, 0 <= x[J, M])

    @objective(model, Max, sum(x[j, m] * C[j, m] for j in J, m in M))

    @constraint(model, [j in J], sum(x[j, m] for m in M) == 1)
    @constraint(model, [m in M_prim], sum(P[j, m] * x[j, m] for j in J) <= T[m])
    @constraint(model, [j in J, m in M], x[j, m] <= 1 - y[j, m])

    set_silent(model)
    optimize!(model)

    return value.(x)
end

function iterative_general_assignment(J::Int, M::Int, P::Matrix{Int}, C::Matrix{Int}, T::Vector{Int})::Vector{Tuple{Int,Int}}
    F = []
    M_prim = [m for m in 1:M]
    y = zeros(Bool, J, M)
    J = [j for j in 1:J]
    M = [m for m in 1:M]

    while length(J) > 0
        x = general_assignment(J, M, M_prim, P, C, T, y)

        for j in axes(x)[1]
            for m in axes(x)[2]

                if x[j, m] ≈ 0.0
                    y[j, m] = true
                end

                if x[j, m] ≈ 1.0
                    push!(F, (j, m))
                    J = filter(x -> x != j, J)
                    T[m] -= P[j, m]
                end

            end
        end

        for m in M_prim
            degree = 0
            weight_sum = 0

            for j in J
                if y[j, m] == false
                    degree += 1
                    weight_sum += x[j, m]
                end
            end

            if degree == 1 || (degree == 2 && weight_sum >= 1)
                M_prim = filter(x -> x != m, M_prim)
            end
        end
    end

    return F
end


filename = "gap1.txt"

f = open(filename, "r")

println("Parsing file: ", filename)

instances = parse(Int64, readline(f))

println("Number of instances: ", instances)

for i in 1:instances
    println("Instance: ", i)
    line = strip(readline(f))
    M, J = [parse(Int, x) for x in split(line, " ")]
    P = Matrix{Int}(undef, J, M)
    C = Matrix{Int}(undef, J, M)
    T = Vector{Int}(undef, M)
    for i in 1:M
        line = split(strip(readline(f)), " ")
        C[:, i] = [parse(Int, x) for x in line]
    end
    for i in 1:M
        line = split(strip(readline(f)), " ")
        P[:, i] = [parse(Int, x) for x in line]
    end
    T = [parse(Int, x) for x in split(strip(readline(f)), " ")]

    sol = iterative_general_assignment(J, M, P, C, T)
    println(sol)
    println("cost: ", calcualte_cost(sol, C))
end

