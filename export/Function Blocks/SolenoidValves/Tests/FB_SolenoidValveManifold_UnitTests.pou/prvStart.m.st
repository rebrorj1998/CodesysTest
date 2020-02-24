(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'hide'}
METHOD prvStart : BOOL
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.prvStart();
testee.station[1] := valves[1];
testee.station[2] := valves[2];
testee.station[3] := valves[3];
testee.station[4] := valves[4];
testee.station[5] := valves[5];
testee.station[6] := valves[6];
testee.station[7] := valves[7];
testee.station[8] := valves[8];
testee.station[9] := valves[9];
testee.station[10] := valves[10];
testee.station[11] := valves[11];
testee.station[12] := valves[12];
testee.station[13] := valves[13];
testee.station[14] := valves[14];
testee.station[15] := valves[15];
testee.station[16] := valves[16];