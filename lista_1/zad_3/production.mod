set Materials := 1..3;
set BasicProducts := {'A', 'B'};
set FinalProducts := {'C', 'D'};
set Products := BasicProducts union FinalProducts;

param minAmount{Materials} >= 0;
param maxAmount{Materials} >= 0;

param price{Products} >= 0;
param cost{Materials} >= 0;
param wasteDisposalCost{Materials, BasicProducts} >= 0;
param wasteRatio{Materials, BasicProducts} >= 0, <= 1;

var materialUsed{Materials, Products} >= 0;
var wasteProduced{Materials, BasicProducts} >= 0;
var wasteUsed {Materials, FinalProducts} >= 0;
var wasteDisposed {Materials, BasicProducts} >= 0;

s.t. MaterialMin {m in Materials}:
  sum{p in Products} materialUsed[m,p] >= minAmount[m];
s.t. MaterialMax {m in Materials}:
  sum{ p in Products} materialUsed[m,p] <= maxAmount[m];

s.t. A1:
  materialUsed[1,'A'] >= 0.2 * sum{m in Materials} materialUsed[m,'A'];
s.t. A2:
  materialUsed[2,'A'] >= 0.4 * sum{m in Materials} materialUsed[m,'A'];
s.t. A3:
  materialUsed[3,'A'] <= 0.1 * sum{m in Materials} materialUsed[m,'A'];

s.t. B1:
  materialUsed[1,'B'] >= 0.1 * sum{m in Materials} materialUsed[m,'B'];
s.t. B2:
  materialUsed[3,'B'] <= 0.3 * sum{m in Materials} materialUsed[m,'B'];

s.t. C1:
  materialUsed[1,'C'] = 0.2 * ((sum{m in Materials} wasteUsed[m,'C']) + materialUsed[1,'C']);
s.t. C2:
  materialUsed[2,'C'] = 0;
s.t. C3:
  materialUsed[3,'C'] = 0;

s.t. D1:
  materialUsed[2,'D'] = 0.3 * ((sum{m in Materials} wasteUsed[m,'D']) + materialUsed[2,'D']);
s.t. D2:
  materialUsed[1,'D'] = 0;
s.t. D3:
  materialUsed[3,'D'] = 0;

s.t. WasteBalanceC{m in Materials}:
  wasteUsed[m,'C'] + wasteDisposed[m, 'A'] = wasteProduced[m,'A'];
s.t. WasteBalanceD{m in Materials}:
  wasteUsed[m,'D'] + wasteDisposed[m, 'B'] = wasteProduced[m,'B'];

s.t. Waste{m in Materials, p in BasicProducts}:
  wasteProduced[m,p] = wasteRatio[m,p] * materialUsed[m,p];

maximize TotalValue:
  sum{p in BasicProducts} (price[p] * sum{m in Materials} (materialUsed[m,p] * (1 - wasteRatio[m,p])))
  + sum{p in FinalProducts} (price[p] * (sum{m in Materials} (materialUsed[m,p] + wasteUsed[m,p]))) 
  - sum{m in Materials, p in BasicProducts} (wasteDisposalCost[m,p] * wasteDisposed[m,p]) 
  - sum{m in Materials, p in Products} (cost[m] * materialUsed[m,p]);

solve;

display materialUsed;
display wasteUsed;
display wasteDisposed;
display
    sum{p in BasicProducts} (price[p] * sum{m in Materials} (materialUsed[m,p] * (1 - wasteRatio[m,p])))
    + sum{p in FinalProducts} (price[p] * (sum{m in Materials} (materialUsed[m,p] + wasteUsed[m,p]))) 
    - sum{m in Materials, p in BasicProducts} (wasteDisposalCost[m,p] * wasteDisposed[m,p]) 
    - sum{m in Materials, p in Products} (cost[m] * materialUsed[m,p]);
data;

param minAmount :=
1 2000
2 3000
3 4000;

param maxAmount :=
1 6000
2 5000
3 7000;

param price :=
'A' 3
'B' 2.5
'C' 0.6
'D' 0.5;

param cost :=
1 2.1
2 1.6
3 1.0;

param wasteRatio :=
1 'A' 0.1
1 'B' 0.2
2 'A' 0.2
2 'B' 0.2
3 'A' 0.4
3 'B' 0.5;

param wasteDisposalCost :=
1 'A' 0.1
1 'B' 0.05
2 'A' 0.1
2 'B' 0.05
3 'A' 0.2
3 'B' 0.4;

end;
