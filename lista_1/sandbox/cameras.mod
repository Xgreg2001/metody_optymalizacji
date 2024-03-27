set Cameras;
set Times;

/* Parameters */
param profit{Cameras} >=0; # one dimensional array of profit
param consumption{Times,Cameras} >=0; # two dimensional array
param capacity{Times} >=0; # one dimensional array of amount of times
param demand{Cameras} >=0; # one dimensional array of the distribution center requirements

/* Variables */
var production{j in Cameras} >=demand[j]; # decision variables plus trivial bounds

/* objective function represents profit */
maximize Profit: sum{j in Cameras} profit[j]*production[j];

s.t. time{i in Times}: sum{j in Cameras} consumption[i,j]*production[j] <=capacity[i];

solve; 

printf{j in Cameras}: '%s = %d\n', j, production[j];


/* Data section */
data;
 
/* Definitions of the sets */
set Cameras:= cub quick vip;
set Times:= manufacture assemble inspect;

/* The initialization of the parameters */
param profit:= cub 3 quick 9 vip 25;
param capacity:= manufacture 250 assemble 350 inspect 150;
param demand:=cub 250 quick 375 vip 150;
param consumption: cub quick vip:=
    manufacture 0.1 0.2 0.7
    assemble 0.2 0.35 0.1
    inspect 0.1 0.2 0.3;
end;

