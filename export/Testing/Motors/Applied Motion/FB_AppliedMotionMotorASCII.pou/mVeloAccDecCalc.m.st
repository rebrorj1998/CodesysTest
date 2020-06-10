(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mVeloAccDecCalc : STRING
VAR_INPUT
	value : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
mVeloAccDecCalc := CONCAT(TO_STRING((value * 0.489)),'$R');