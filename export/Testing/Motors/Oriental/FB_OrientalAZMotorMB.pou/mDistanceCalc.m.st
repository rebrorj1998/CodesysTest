(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mDistanceCalc : DINT
VAR_INPUT
	distanceSP : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF directDataOp.OperationType.diDint = eOrientalOperationType.Absolute_Positioning OR directDataOp.OperationType.diDint = eOrientalOperationType.Absolute_Push THEN
	mDistanceCalc := TO_DINT((distanceSP - zeroOffset) * TO_REAL(stepsPerInchSP));
ELSE
	mDistanceCalc := TO_DINT((distanceSP) * TO_REAL(stepsPerInchSP));
END_IF