(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mVeloAccDecCalc : DINT
VAR_INPUT
	value : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
mVeloAccDecCalc := TO_DINT(value * TO_REAL(stepsPerInchSP));