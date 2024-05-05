using JuMP, GLPK
using Plots

n = 5  # Liczba zadań
m = 4  # Liczba procesorów
# Czasy wykonania dla każdego zadania na każdym procesorze
times = [
    [3, 2, 4, 3],  # Czasy dla zadania 1 na procesorach P1, P2, ..., Pm
    [2, 3, 3, 2],  # Czasy dla zadania 2
    [4, 1, 2, 1],  # Czasy dla zadania 3
    [1, 5, 3, 4],  # Czasy dla zadania 4
    [5, 2, 1, 2]   # Czasy dla zadania 5
]

model = Model(GLPK.Optimizer)

@variable(model, x[1:n, 1:n], Bin)  # x[i, j] = 1, jeśli zadanie i jest na miejscu j
@variable(model, t_start[1:n, 1:m] >= 0)  # Czas rozpoczęcia zadania na każdym procesorze
@variable(model, t_end[1:n, 1:m] >= 0)  # Czas zakończenia zadania na każdym procesorze
@variable(model, Cmax)

# Każde zadanie musi być na jednej pozycji
for i in 1:n
    @constraint(model, sum(x[i, j] for j in 1:n) == 1)
end

# Na każdej pozycji musi być jedno zadanie
for j in 1:n
    @constraint(model, sum(x[i, j] for i in 1:n) == 1)
end

for j in 1:n
    for p in 1:m
        if p == 1
            if j == 1
                @constraint(model, t_start[j, p] == 0) # od razu rozpocznij pracę
            end
        else
            @constraint(model, t_start[j, p] >= t_end[j, p-1]) # rozpocznij pracę dopiero po zakończeniu pracy na poprzednim procesorze
        end
        if j > 1
            @constraint(model, t_start[j, p] >= t_end[j-1, p]) # rozpocznij pracę dopiero po zakończeniu pracy na poprzednim zadaniu
        end
        @constraint(model, t_end[j, p] == t_start[j, p] + sum(times[k][p] * x[k, j] for k in 1:n)) # obliczenie końca pracy
    end
end

@constraint(model, Cmax >= t_end[n, m])

@objective(model, Min, Cmax)

optimize!(model)

println("Minimalne Cmax = ", objective_value(model))
println("Kolejność zadań:")
for j in 1:n
    for i in 1:n
        if value(x[i, j]) > 0.9
            println("Pozycja ", j, ": Zadanie ", i)
        end
    end
end


# Ustalanie kolorów dla każdego zadania wykorzystując paletę kolorów
colors = palette(:gnuplot, n)

# Inicjalizacja wykresu
plot(title="Diagram Gantt’a dla Harmonogramu Zadań", xlabel="Czas", ylabel="Procesor", legend=true)

for i in 1:n
    for j in 1:n
        if value(x[i, j]) > 0.9  # Sprawdź, które zadanie jest na której pozycji
            for p in 1:m
                start_time = value(t_start[j, p])
                end_time = value(t_end[j, p])
                plot!([start_time, end_time], [p, p], line=(8, :solid, colors[i]), label="")
                if p == 1
                    plot!([0, 0], [1, 1], line=(8, :solid, colors[i]), label="Zadanie $i")
                end
            end
        end
    end
end

savefig("zad3.pdf")

