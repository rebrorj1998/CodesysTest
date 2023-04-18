(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ScaledProfileTargetPostion := targetPosDist * TO_REAL(stepsPerInch);
IF reversePolarity THEN
	ScaledProfileTargetPostion := ScaledProfileTargetPostion * -1;
END_IF