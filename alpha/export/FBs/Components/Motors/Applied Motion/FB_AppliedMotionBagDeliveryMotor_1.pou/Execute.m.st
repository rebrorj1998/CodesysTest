(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
SUPER^.Execute();

//
waitForMove();

//
_moveFinalONS(CLK := _moveFinal);
_moveDistanceONS(CLK := _moveDistance);

CASE moveDistanceState OF
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveDistance THEN
			moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:
		IF rearMotor THEN
			ExecuteStoredProgram(3);
		END_IF						
		IF commandSuccessful OR NOT rearMotor THEN
			commandSuccessful := FALSE;
			moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff:		
		IF commandSuccessful THEN
			moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
		END_IF
																
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					
		_moveDistance := FALSE;
		sclCommand := 16#0;
		parameter1 := 16#0;
		commandSuccessful := FALSE;
		commands.FeedToLength := TRUE;
		moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
																											
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		
		IF commandSuccessful THEN
			_moveDone := TRUE;
			moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
		END_IF														
END_CASE

CASE moveDistanceFinalState OF
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveFinal THEN
			moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:				sclCommand := 16#534F; //Output off
															parameter1 := 16#48B2;
															commands.SendHostCommand := TRUE;
															IF commandSuccessful THEN
																commandSuccessful := FALSE;
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff;
															END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff:		
															IF commandSuccessful THEN
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
															END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					sclCommand := 16#0;
															parameter1 := 16#0;
															commandSuccessful := FALSE;	
															commands.FeedToLength := TRUE;
															moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
															
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		IF commandSuccessful AND InPosition THEN	
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOn;
															END_IF
														
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOn :					sclCommand := 16#534F; // Output on
															parameter1 := 16#4CB2;
															
															commandSuccessful := FALSE;
															commands.SendHostCommand := TRUE;
															_moveFinal := FALSE;
															moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOn;
															
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOn :		
															IF commandSuccessful THEN
																_moveDone := TRUE;
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
															END_IF
																
END_CASE

IF manualFinalMovePB THEN
    MoveDistanceFinal(distance := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    manualFinalMovePB := FALSE;
END_IF