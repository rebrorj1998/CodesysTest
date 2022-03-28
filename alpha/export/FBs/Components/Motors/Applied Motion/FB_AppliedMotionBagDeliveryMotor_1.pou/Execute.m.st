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

//
IF _reset THEN
	ackRequest := FALSE;
	tensionFault := FALSE;
	_moveDistance := FALSE;
	_moveFinal := FALSE;
	_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
	_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
END_IF

// 
IF position = BAG_DELIVERY_MOTOR_POSITION.Rear THEN
	_tensionFaultDwellTimer(IN :=  velocity > VELOCITY_THRESHOLD_FOR_TENSION_FAULT);
	IF _tensionFaultDwellTimer.Q THEN
		commandSuccessful := FALSE;
		tensionFault := TRUE;
	END_IF		
END_IF

//
_delayTimer();

//
CASE _moveDistanceState OF
	
	AMP_EIP_MOVE_INITIAL_STATES.Idle:						
		IF _moveDistance THEN
			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
		END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff:
 		IF position = BAG_DELIVERY_MOTOR_POSITION.Rear THEN
 			TriggerPointToPointMode();
 		END_IF						
 		IF commandSuccessful OR position = BAG_DELIVERY_MOTOR_POSITION.Front  THEN
 			commandSuccessful := FALSE;
  			_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff;
 		END_IF
		
	AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff:
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			ackRequest := TRUE;
			IF ack THEN
				ackRequest := FALSE;
				_delayTimer.IN := FALSE;
				_moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
			END_IF
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
		IF position = BAG_DELIVERY_MOTOR_POSITION.Rear THEN
			TriggerPointToPointMode();
		END_IF	
		IF commandSuccessful OR position = BAG_DELIVERY_MOTOR_POSITION.Front THEN
			commandSuccessful := FALSE;
  			_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff;
		END_IF
		
	AMP_EIP_MOVE_INITIAL_STATES.AckOutputOff:
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			ackRequest := TRUE;
			IF ack THEN
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
		IF position = BAG_DELIVERY_MOTOR_POSITION.Rear THEN
			TriggerTorqueMode();
		END_IF	
		IF commandSuccessful OR position = BAG_DELIVERY_MOTOR_POSITION.Front THEN
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
