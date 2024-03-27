/* decision variables*/

var x1 >= 0;
var x2 >=0;

/* Objective function */

maximize functionName: 4*x1 +5*x2;

/* Constraints */

s.t. l1: x1 + 2*x2 <= 40;
s.t. l2: 4*x1 + 3*x2 <= 120;

end;

