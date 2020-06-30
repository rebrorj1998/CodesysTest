(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mDistanceCalc : STRING
VAR_INPUT
	distanceSP : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
mDistanceCalc := CONCAT(TO_STRING(TO_DINT((distanceSP *TO_REAL(stepsPerInchSP)))),'$R');