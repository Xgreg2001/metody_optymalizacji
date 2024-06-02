# Kamil Włodarski
using JuMP, GLPK, Random

# liczba cech
m = 10

# liczba serwerowni
n = 10

Random.seed!(1234)

# czas odczytu z serwera
T = [rand(1:10) for i in 1:n]
println("T = $(T)")

# macierz cech i serwerów
q = [rand(0:1) for i in 1:m, j in 1:n]
println("q = ")
display(q)

model = Model(GLPK.Optimizer)
# set_silent(model)

# wektor binarny - wybór serwera
@variable(model, x[1:n] >= 0, integer = true)

# każda cecha musi być wybrana przynajmniej raz
@constraint(model, [i = 1:m], sum(x[j] * q[i, j] for j in 1:n) >= 1)

# minimalizacja czasu
@objective(model, Min, sum(x[j] * T[j] for j in 1:n))

# print(model)

optimize!(model)

println("Wybrane serwery: ", value.(x))

println("Czas: ", objective_value(model))


