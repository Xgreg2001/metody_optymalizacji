set Week := {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};

set GroupNum := 1..4;

set Subject := {'Algebra', 'Analysis', 'Physics', 'Mineral Chemistry', 'Organic Chemistry'};

param groupStart{Subject, GroupNum} >= 0, < 24;
param groupFinish{Subject, GroupNum} >= 0, < 24;
param groupDay{Subject, GroupNum} symbolic in Week;
param groupRating{Subject, GroupNum} integer >= 0;

set conflictingGroups := {
    (s1,g1,s2,g2) in (Subject cross GroupNum cross Subject cross GroupNum) : 
    s1 != s2 and groupDay[s1, g1] = groupDay[s2, g2] and
    groupFinish[s1, g1] > groupStart[s2, g2] and
    groupFinish[s2, g2] > groupStart[s1, g1]
};

var chosenGroup{Subject, GroupNum} binary;

s.t. GroupChoice{s in Subject}:
    sum{g in GroupNum} chosenGroup[s, g] = 1;

s.t. NoConflicts{(s1, g1, s2, g2) in conflictingGroups}:
    chosenGroup[s1, g1] + chosenGroup[s2, g2] <= 1;
 
s.t. DailyTimeLimit{d in Week}:
    sum{g in GroupNum, s in Subject: groupDay[s, g] = d} chosenGroup[s, g] * (groupFinish[s,g] - groupStart[s,g]) <= 4;

s.t. LaunchBrake{d in Week}:
    sum{g in GroupNum, s in Subject: groupDay[s, g] = d and groupStart[s, g] >= 12 and groupFinish[s, g] <= 14} (chosenGroup[s, g] * (groupFinish[s,g] - groupStart[s,g]))
    + sum{g in GroupNum, s in Subject: groupDay[s, g] = d and groupStart[s, g] < 12 and groupFinish[s, g] <= 14} (chosenGroup[s, g] * (groupFinish[s,g] - 12)) 
    + sum{g in GroupNum, s in Subject: groupDay[s, g] = d and groupStart[s, g] >= 12 and groupFinish[s, g] > 14} (chosenGroup[s, g] * (14 - groupStart[s,g])) <= 1;

s.t. Training:
    sum{g in GroupNum, s in Subject: 
    	groupDay[s,g] = 'Monday' 
	and ((groupStart[s, g] >= 13 and groupStart[s,g] <= 15) or (groupFinish[s, g] >= 13 and groupFinish[s,g] <= 15))} 
    chosenGroup[s, g] + 
    sum{g in GroupNum, s in Subject: 
    	groupDay[s,g] = 'Wednesday' 
    	and ((groupStart[s, g] >= 11 and groupStart[s,g] <= 13) or (groupFinish[s, g] >= 11 and groupFinish[s,g] <= 13))} 
    chosenGroup[s, g] +
    sum{g in GroupNum, s in Subject: 
    	groupDay[s,g] = 'Wednesday' 
	and ((groupStart[s, g] >= 13 and groupStart[s,g] <= 15) or (groupFinish[s, g] >= 13 and groupFinish[s,g] <= 15))} 
    chosenGroup[s, g] <= 2;

maximize TotalRating:
    sum{g in GroupNum, s in Subject} groupRating[s, g] * chosenGroup[s, g];

solve;

display chosenGroup;
display sum{g in GroupNum, s in Subject} groupRating[s, g] * chosenGroup[s, g];

data;

param groupStart : 1 2 3 4 :=
'Algebra' 13 10 10 11
'Analysis' 13 10 11 8
'Physics' 8 10 15 17
'Mineral Chemistry' 8 8 13 13
'Organic Chemistry' 9 10.5 11 13;

param groupFinish : 1 2 3 4 :=
'Algebra' 15 12 12 13
'Analysis' 15 12 13 10
'Physics' 11 13 18 20
'Mineral Chemistry' 10 10 15 15
'Organic Chemistry' 10.5 12 12.5 14.5;

param groupDay : 1 2 3 4 :=
'Algebra' 'Monday' 'Tuesday' 'Wednesday' 'Wednesday'
'Analysis' 'Monday' 'Tuesday' 'Wednesday' 'Thursday'
'Physics' 'Tuesday' 'Tuesday' 'Thursday' 'Thursday'
'Mineral Chemistry' 'Monday' 'Monday' 'Thursday' 'Friday'
'Organic Chemistry' 'Monday' 'Monday' 'Friday' 'Friday';

param groupRating : 1 2 3 4 :=
'Algebra' 5 4 10 5
'Analysis' 4 4 5 6
'Physics' 3 5 7 8
'Mineral Chemistry' 10 10 7 5
'Organic Chemistry' 0 5 3 4;

end;
