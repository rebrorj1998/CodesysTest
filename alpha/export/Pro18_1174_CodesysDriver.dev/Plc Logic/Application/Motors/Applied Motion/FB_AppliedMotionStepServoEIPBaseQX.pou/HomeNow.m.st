(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD HomeNow(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;
parameter1 := 1;
pointToPointAccelSetpoint := 1000;
pointToPointDecelSetpoint := 1000;
velocitySetpoint := 2500;
distanceToMoveInSteps := 0;
commands.sendQAndExecute := TRUE;

//homeRequiredIndication := FALSE;