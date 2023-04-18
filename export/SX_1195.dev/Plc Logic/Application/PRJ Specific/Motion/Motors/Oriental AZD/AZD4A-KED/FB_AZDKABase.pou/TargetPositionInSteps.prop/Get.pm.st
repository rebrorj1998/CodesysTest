(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TargetPositionInSteps := (targetPosDist - zeroOffset) * TO_REAL(axisData.config.stepsPerInch);
IF axisData.config.reversePolarity THEN
	TargetPositionInSteps := TargetPositionInSteps * -1;
END_IF