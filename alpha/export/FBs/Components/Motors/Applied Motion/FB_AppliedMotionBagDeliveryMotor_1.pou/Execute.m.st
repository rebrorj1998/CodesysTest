(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
VAR CONSTANT
	VELOCITY_THRESHOLD_FOR_TENSION_FAULT : INT := 1700;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
SUPER^.Execute();

IF intercommunications = BAG_DELIVERY_MOTOR_INTERCOMMUNICATION.EthernetIP THEN
	// [EIP, Rear] If velocity reaches threshold for set duration, fault
	IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
		_tensionFaultDwellTimer(IN :=  velocity > VELOCITY_THRESHOLD_FOR_TENSION_FAULT);
		IF _tensionFaultDwellTimer.Q THEN
			commandSuccessful := FALSE;
			tensionFault := TRUE;
		END_IF		
	END_IF
	
	// Reset motor state and variables
	IF _reset THEN
		ackRequest := FALSE;
		tensionFault := FALSE;
		_moveDistance := FALSE;
		_moveFinal := FALSE;
		_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
		_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
	END_IF
END_IF

// Used in state engine to delay between moves
_delayTimer();

//
CASE _moveDistanceState OF
	
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveDistance THEN
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:
		IF intercommunications = BAG_DELIVERY_MOTOR_INTERCOMMUNICATION.EthernetIP THEN
			IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
 				TriggerPointToPointMode();
 			END_IF
			IF commandSuccessful OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Front THEN
				commandSuccessful := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff;
			END_IF
		ELSE
			sclCommand := 16#534F; // Output off
			parameter1 := 16#48B2;
			commands.SendHostCommand := TRUE;
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff;
			END_IF
		END_IF
		
	AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff:
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			ackRequest := TRUE; // Let parent know youre ready to move motor
			IF ack THEN // Parent acks that your sibling is ready
				ackRequest := FALSE;
				_delayTimer.IN := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
			END_IF
		END_IF

	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff:		
		IF commandSuccessful THEN
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
		END_IF		
																
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					
		FeedToLength();
		_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
																											
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		
		IF commandSuccessful THEN
			commandSuccessful := FALSE;
			_moveDone := TRUE;
			_moveDistance := FALSE;
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
		END_IF														
END_CASE

CASE _moveDistanceFinalState OF
	
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveFinal THEN
			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:
		IF intercommunications = BAG_DELIVERY_MOTOR_INTERCOMMUNICATION.EthernetIP THEN
			IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
 				TriggerPointToPointMode();
 			END_IF
			IF commandSuccessful OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Front THEN
				commandSuccessful := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff;
			END_IF
		ELSE
			sclCommand := 16#534F; // Output off
			parameter1 := 16#48B2;
			commands.SendHostCommand := TRUE;
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff;
			END_IF
		END_IF
		
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff:		
		IF commandSuccessful THEN
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
		END_IF		
		
	AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff:
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			ackRequest := TRUE; // Let parent know youre ready to move motor
			IF ack THEN // Parent acks that your sibling is ready
				ackRequest := FALSE;
				_delayTimer.IN := FALSE;
				_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
			END_IF
		END_IF	
															
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					
		FeedToLength();
		_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
																			
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		
		IF commandSuccessful AND InPosition THEN
			_delayTimer.IN := TRUE;
			IF _delayTimer.Q THEN
				_delayTimer.IN := FALSE;
				commandSuccessful := FALSE;
				_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOn;
			END_IF	
		END_IF
														
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOn:					
		IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
			TriggerTorqueMode();
		END_IF	
		IF commandSuccessful OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Front THEN
			commandSuccessful := FALSE;
			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOn;
		END_IF
																									
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOn:	
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			_moveDone := TRUE;
			_moveFinal := FALSE;
			_delayTimer.IN := FALSE;
			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
		END_IF													
END_CASE
