(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
SUPER^.Execute();

//
_waitForMove();

//
_moveFinalONS(CLK := _moveFinal);
_moveDistanceONS(CLK := _moveDistance);


IF _reset THEN
	_moveDistance := FALSE;
	_moveFinal := FALSE;
	ackRequest := FALSE;
	_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
	_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
END_IF

CASE _moveDistanceState OF
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveDistance THEN
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:
 		IF reversePolarity THEN
 			ExecuteStoredProgram(3);
 		END_IF						
 		IF commandSuccessful OR NOT reversePolarity THEN
 			commandSuccessful := FALSE;
  			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff;
 		END_IF
		
	AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff:
		_waitForMove.PT := T#10MS;
		_waitForMove.IN := TRUE;
		IF _waitForMove.Q THEN
			ackRequest := TRUE;
			IF ack THEN
				ackRequest := FALSE;
				_waitForMove.IN := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
			END_IF
		END_IF		
																
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					
		_moveDistance := FALSE;
		sclCommand := 16#0;
		parameter1 := 16#0;
		commandSuccessful := FALSE;
		commands.FeedToLength := TRUE;
		_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
																											
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		
		IF commandSuccessful THEN
			_moveDone := TRUE;
			commandSuccessful := FALSE;
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
		END_IF														
END_CASE

CASE _moveDistanceFinalState OF
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveFinal THEN
			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:				
		IF reversePolarity THEN
			ExecuteStoredProgram(3);
		END_IF	
		IF commandSuccessful OR NOT reversePolarity THEN
			commandSuccessful := FALSE;
  			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff;
		END_IF
		
	AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff:
		_waitForMove.PT := T#10MS;
		_waitForMove.IN := TRUE;
		IF _waitForMove.Q THEN
			ackRequest := TRUE;
			IF ack THEN
				ackRequest := FALSE;
				_waitForMove.IN := FALSE;
				_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
			END_IF
		END_IF	
															
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					
		sclCommand := 16#0;
		parameter1 := 16#0;
		commandSuccessful := FALSE;	
		commands.FeedToLength := TRUE;
		_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
																			
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		
		IF commandSuccessful AND InPosition THEN
			_waitForMove.PT := T#10MS;
			_waitForMove.IN := TRUE;
			IF _waitForMove.Q THEN
				_waitForMove.IN := FALSE;
				commandSuccessful := FALSE;
				_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOn;
			END_IF	
		END_IF
														
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOn:					
		IF reversePolarity THEN
			ExecuteStoredProgram(2);
		END_IF	
		IF commandSuccessful OR NOT reversePolarity THEN
			commandSuccessful := FALSE;
			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOn;
		END_IF
																									
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOn:	
		_waitForMove.PT := T#10MS;
		_waitForMove.IN := TRUE;
		IF _waitForMove.Q THEN
			_moveDone := TRUE;
			_moveFinal := FALSE;
			_waitForMove.IN := FALSE;
			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
		END_IF
																
END_CASE

//
IF manualFinalMovePB THEN
    MoveDistanceFinal(distance := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    manualFinalMovePB := FALSE;
END_IF