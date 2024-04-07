/* input data */
set Towns;
param standardCampers{i in Towns}, integer;
param vipCampers{i in Towns}, integer;
param cost{i in Towns, j in Towns}, integer;
param vipMultiplier;

/* The variables */
var movedStandard{i in Towns, j in Towns}, integer, >= 0;
var movedVip{i in Towns, j in Towns}, integer, >= 0;

/* The objective function */
minimize obj : sum{i in Towns, j in Towns} (movedStandard[i, j] + movedVip[i, j] * vipMultiplier) * cost[i, j];

/* The constraint */

s.t. enoughStandard{i in Towns}: sum{j in Towns} (movedStandard[j, i] + movedVip[j, i]) - sum{j in Towns} (movedStandard[i, j] + movedVip[i, j]) + standardCampers[i] + vipCampers[i] >= 0;
s.t. enoughVIP{i in Towns}: (sum{j in Towns} movedVip[j, i]) - (sum{j in Towns} movedVip[i, j]) + vipCampers[i] >= 0;
s.t. movedStandardMax{i in Towns}: sum{j in Towns} movedStandard[i, j] <= max(0, standardCampers[i]);
s.t. movedVipMax{i in Towns}: sum{j in Towns} movedVip[i, j] <= max(0, vipCampers[i]);

solve;

/* Displaying results */
display movedStandard;
display movedVip;
display sum{i in Towns, j in Towns} (movedStandard[i, j] + movedVip[i, j] * vipMultiplier) * cost[i, j];

/* Data section */
data;

set Towns := Warszawa Gdansk Szczecin Wroclaw Krakow Berlin Rostok Lipsk Praga Brno Bratyslawa Koszyce Budapeszt;

param standardCampers := Warszawa 14, Gdansk -20, Szczecin 12, Wroclaw -8, Krakow 10, Berlin -16, Rostok -2,
                      Lipsk -3, Praga 10, Brno -9, Bratyslawa -4, Koszyce -4, Budapeszt -8;

param vipCampers := Warszawa -4, Gdansk 2, Szczecin 4, Wroclaw 10, Krakow -8, Berlin -4, Rostok 4,
                 Lipsk 10, Praga -4, Brno 2, Bratyslawa 8, Koszyce 4, Budapeszt 4;

param cost : Warszawa Gdansk Szczecin Wroclaw Krakow Berlin Rostok Lipsk Praga Brno Bratyslawa Koszyce Budapeszt :=
    Warszawa 0 340 567 355 292 574 797 727 688 539 661 528 858
    Gdansk 340 0 469 482 606 511 622 726 745 763 885 852 1082
    Szczecin 567 469 0 395 653 150 262 364 500 613 751 896 1024
    Wroclaw 355 482 395 0 276 346 574 374 336 404 412 519 723
    Krakow 292 606 653 276 0 599 827 626 535 333 455 256 395
    Berlin 574 511 150 346 599 0 233 191 352 556 679 846 876
    Rostok 797 622 262 574 827 233 0 382 580 785 908 1075 1104
    Lipsk 727 726 364 374 626 191 382 0 257 454 577 875 773
    Praga 688 745 500 336 535 352 580 257 0 206 328 659 525
    Brno 539 763 613 404 333 556 785 454 206 0 130 458 326
    Bratyslawa 661 885 751 412 455 679 908 577 328 130 0 405 201
    Koszyce 528 852 896 519 256 846 1075 875 659 458 405 0 262
    Budapeszt 858 1082 1024 723 395 876 1104 773 525 326 201 262 0;


param vipMultiplier := 1.15;


end;
