(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD HomeNow(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;
parameter1 := 1;
pointToPointAccelSetpoint := 50;
pointToPointDecelSetpoint := 50;
velocitySetpoint := 500;
distanceToMoveInSteps := 0;
commands.sendQAndExecute := TRUE;

//homeRequiredIndication := FALSE;