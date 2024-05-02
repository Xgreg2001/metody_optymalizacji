# Kamil Włodarski
using JuMP, GLPK, Random

Random.seed!(1234)

# liczba funkcji
m = 10
println("m = ", m)

# liczba podprogramów
n = 10
println("n = ", n)

# pamięć potrzebna na podprogramy
r = [rand(1:10) for i in 1:m, j in 1:n]
println("r = ")
display(r)

# czas wykonania podprogramów
t = [rand(1:10) for i in 1:m, j in 1:n]
println("t = ")
display(t)

# zbiór funkcji do obliczenia
I = [i for i in 1:m if rand() < 0.5]
println("I = ", I)

# maksymalna liczba komórek pamięci
M = 10
println("M = ", M)

model = Model(GLPK.Optimizer)

# wybór podprogramów
@variable(model, x[1:m, 1:n], binary = true)

# ograniczenie na pamięć
@constraint(model, sum(r[i, j] * x[i, j] for i in 1:m, j in 1:n) <= M)

# Wyszystkie funkcje z I muszą być obliczone
@constraint(model, [i in I], sum(x[i, j] for j in 1:n) >= 1)

# minimalizacja czasu
@objective(model, Min, sum(t[i, j] * x[i, j] for i in 1:m, j in 1:n))

print(model)

optimize!(model)

println("Czas: ", objective_value(model))

println("x = ")
for i in 1:m
        for j in 1:n
                if value(x[i, j]) > 0.5
                        println("x[", i, ", ", j, "] = ", value(x[i, j]))
                end
        end
end
