/* input data */
param n, integer, >= 1;
param a{i in 1..n, j in 1..n} := 1 / (i + j - 1);
param c{i in 1..n} := sum{j in 1..n} 1 / (i + j - 1);

/* The variables */
var x{1..n} >= 0;

/* The objective function */
minimize obj: sum{i in 1..n} c[i]*x[i];

/* The constraint */
s.t. constraint{i in 1..n}: sum{j in 1..n} a[i, j] * x[j] == c[i];  

solve;

/* Displaying results */
printf{i in 1..n}: "x[%d]=%f\n", i, x[i];
printf: "Error: %f", sqrt(sum{i in 1..n} (x[i] - 1)*(x[i] - 1)) / 1;


/* Data section */
data;

/* 7 is max we can compute */
param n := 7;

end;
