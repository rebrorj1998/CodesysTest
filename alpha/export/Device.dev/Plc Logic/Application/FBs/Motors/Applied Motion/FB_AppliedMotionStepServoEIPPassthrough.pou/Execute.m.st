(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.Execute();
timerHomeDelay();
homeRequiredONS(CLK := homeRequiredIndication);

//IF _reset OR homeRequiredONS.Q THEN
IF _reset THEN
	homingState := JAW_HOMING_STATES.Idle;
	_homeNow := FALSE;
	timerHomeDelay.IN := FALSE;
END_IF

CASE homingState OF
	JAW_HOMING_STATES.Idle:						IF _homeNow THEN
													//IF NOT driveInputs[10].2 THEN
													//	homingState := JAW_HOMING_STATES.MoveForwardFromSensor;
													//ELSE 
														homingState := JAW_HOMING_STATES.StartHoming;
													//END_IF
													_homeNow := FALSE;
												END_IF
												
	JAW_HOMING_STATES.MoveForwardFromSensor:	commandSuccessful := FALSE;
												velocitySetpoint := 2583;
												pointToPointAccelSetpoint := 1000;
												pointToPointDecelSetpoint := 1000;
												distanceToMoveInSteps := -4000;
												commands.FeedToLength := TRUE;
												homingState := JAW_HOMING_STATES.MovingForwardFromSensor;
												
	JAW_HOMING_STATES.MovingForwardFromSensor:	timerHomeDelay.PT := T#200MS;
												timerHomeDelay.IN := TRUE;
												IF timerHomeDelay.Q THEN
													IF (NOT Moving AND InPosition) THEN
														homingState := JAW_HOMING_STATES.StartHoming;
														timerHomeDelay.IN := FALSE;
                                                       END_IF
												END_IF
												
	JAW_HOMING_STATES.StartHoming:				commandSuccessful := FALSE;
												velocitySetpoint := 1250;
												pointToPointAccelSetpoint := 10;
												pointToPointDecelSetpoint := 10;
												distanceToMoveInSteps := 1;
												ExecuteStoredProgram(2);
												homingState := JAW_HOMING_STATES.Homing;
												
	JAW_HOMING_STATES.Homing:					timerHomeDelay.PT := T#200MS;
												timerHomeDelay.IN := TRUE;
												IF timerHomeDelay.Q THEN
													IF (NOT SUPER^.Homing) THEN
														homingState := JAW_HOMING_STATES.HomeComplete;
														timerHomeDelay.IN := FALSE;
                                                       END_IF
												END_IF 
												
	JAW_HOMING_STATES.HomeComplete:				//MoveToPosition(2, 1000,1000,2583);
												homingState := JAW_HOMING_STATES.Idle;

	JAW_HOMING_STATES.MovingToTwoInches : 		timerHomeDelay.PT := T#200MS;
												timerHomeDelay.IN := TRUE;
												IF timerHomeDelay.Q THEN
													IF (NOT Moving AND InPosition) THEN
														homingState := JAW_HOMING_STATES.SetLimits;
														timerHomeDelay.IN := FALSE;
                                                       END_IF
												END_IF 
												
	JAW_HOMING_STATES.SetLimits :				commandSuccessful := FALSE;
												ExecuteStoredProgram(3);
												homingState := JAW_HOMING_STATES.Idle;
												
	
END_CASE

