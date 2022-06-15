(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
SUPER^.Execute();

// Used in state engine to delay between moves
_delayTimer();

// If motor velocity is greater then threshold for 2 seconds, fault
_tensionFaultDwellTimer(IN := ABS(velocity) > VELOCITY_THRESHOLD_FOR_TENSION_FAULT);
IF _tensionFaultDwellTimer.Q AND NOT HMIData.enableDryCycle THEN
	tensionFault := TRUE;
END_IF

// Clear Params
IF _restoreToDefault THEN
	_restoreToDefault := FALSE;
	_state := BAG_DELIVERY_MOVE_STATES.Idle;
	commandSuccessful := FALSE;
	tensionFault := FALSE;
	ackRequest := FALSE;
	ack := FALSE;
END_IF

//
CASE _state OF
	BAG_DELIVERY_MOVE_STATES.Idle:
		IF _moveDistance THEN
			_moveDistance := FALSE;
			_state := BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode;
			commandSuccessful := FALSE;
		END_IF
															
	BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode:
		IF EIP THEN
			IF RearMotor THEN
				TriggerPointToPointMode();	
			END_IF						
			IF commandSuccessful OR NOT RearMotor THEN
				commandSuccessful := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.AckPointToPointMode;
			END_IF
		ELSIF NOT EIP THEN
			sclCommand := SCL_SO; 
			parameter1 := O2_H;
			commands.SendHostCommand := TRUE;
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor;
			END_IF
		END_IF
		
	BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff:		
		IF commandSuccessful THEN
			_state := BAG_DELIVERY_MOVE_STATES.MoveMotor;
		END_IF
		
	BAG_DELIVERY_MOVE_STATES.AckPointToPointMode:
		_delayTimer.PT := T#10MS;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			ackRequest := TRUE; // Request acknowledgment from parent class
			IF ack THEN // Parent class acknowledges this motor and sibling are ready to move
				ackRequest := FALSE;
				_delayTimer.IN := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.MoveMotor;
			END_IF
		END_IF		
																
	BAG_DELIVERY_MOVE_STATES.MoveMotor: 					
		FeedToLength();
		_state := BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor;
																											
	BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor:
		IF NOT _moveFinal THEN
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_moveDone := TRUE;
				_state := BAG_DELIVERY_MOVE_STATES.Idle;
			END_IF
		ELSE
			IF commandSuccessful AND InPosition THEN
				_delayTimer.PT := T#10MS;
				_delayTimer.IN := TRUE;
				IF _delayTimer.Q THEN
					_delayTimer.IN := FALSE;
					commandSuccessful := FALSE;
					_state := BAG_DELIVERY_MOVE_STATES.SetToTorqueMode;
				END_IF	
			END_IF
		END_IF 

	BAG_DELIVERY_MOVE_STATES.SetToTorqueMode:	
		IF EIP THEN
			IF RearMotor THEN
				TriggerTorqueMode();
			END_IF	
			IF commandSuccessful OR NOT RearMotor THEN
				commandSuccessful := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOn;
			END_IF
		ELSE
			TriggerTorqueMode();
			_state := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOn;
		END_IF				
																									
	BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOn:
		IF EIP THEN
			_delayTimer.PT := T#10MS;
			_delayTimer.IN := TRUE;
			IF _delayTimer.Q THEN
				_moveDone := TRUE;
				_moveFinal := FALSE;
				_delayTimer.IN := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.Idle;
			END_IF
		ELSE
			IF commandSuccessful THEN
				_moveDone := TRUE;
				_state := BAG_DELIVERY_MOVE_STATES.Idle;
				commandSuccessful := FALSE;
			END_IF
		END_IF																	
END_CASE
