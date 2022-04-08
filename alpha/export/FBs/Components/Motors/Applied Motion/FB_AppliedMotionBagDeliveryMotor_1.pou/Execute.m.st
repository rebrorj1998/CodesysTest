(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
SUPER^.Execute();

// Used in state engine to delay between moves
_delayTimer();

//
CASE _stateInitalize OF
	BAG_DELIVERY_INIT_STATES.Idle:
		IF interconnect = BAG_DELIVERY_IC.EIP AND placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
			// Start state machine on initalize
			IF _initialize THEN
				_stateInitalize := BAG_DELIVERY_INIT_STATES.Reset;	
			END_IF
			
			// If motor velocity is greater then threshold for 2 seconds, fault
			_tensionFaultDwellTimer(IN := ABS(velocity) > VELOCITY_THRESHOLD_FOR_TENSION_FAULT);
			IF _tensionFaultDwellTimer.Q AND NOT HMIData.enableDryCycle THEN
				tensionFault := TRUE;
			END_IF
		END_IF				
	
	BAG_DELIVERY_INIT_STATES.Reset:
		tensionFault := FALSE; // Clear tension fault on reset
		_stateInitalize := BAG_DELIVERY_INIT_STATES.SetTorque;	
		
	BAG_DELIVERY_INIT_STATES.SetTorque:
		SetTorque(torque := 60);
		_stateInitalize := BAG_DELIVERY_INIT_STATES.SettingTorque;	
		
	BAG_DELIVERY_INIT_STATES.SettingTorque:
		IF commandSuccessful THEN
			_stateInitalize := BAG_DELIVERY_INIT_STATES.TorqueSet;	
		END_IF
		
	BAG_DELIVERY_INIT_STATES.TorqueSet:
		commandSuccessful := FALSE;
		_stateInitalize := BAG_DELIVERY_INIT_STATES.SetTorqueMode;	
		
	BAG_DELIVERY_INIT_STATES.SetTorqueMode:
		TriggerTorqueMode();	
		_stateInitalize := BAG_DELIVERY_INIT_STATES.SettingTorqueMode;	
	
	BAG_DELIVERY_INIT_STATES.SettingTorqueMode:
		IF commandSuccessful THEN
			_stateInitalize := BAG_DELIVERY_INIT_STATES.TorqueModeSet;
		END_IF
	BAG_DELIVERY_INIT_STATES.TorqueModeSet:
		commandSuccessful := FALSE;
		_initialize := FALSE;
		_stateInitalize := BAG_DELIVERY_INIT_STATES.Idle;
END_CASE

//
CASE _state OF
	BAG_DELIVERY_MOVE_STATES.Idle:
		IF _moveDistance THEN
			_state := BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode;
		END_IF
															
	BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode:
		IF interconnect = BAG_DELIVERY_IC.EIP AND NOT jog THEN
			IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
				TriggerPointToPointMode();
			END_IF						
			IF commandSuccessful OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Front THEN
				commandSuccessful := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.AckPointToPointMode;
			END_IF
		ELSE
			sclCommand := SCL_SO; 
			parameter1 := O2_H;
			commands.SendHostCommand := TRUE;
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_state := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff;
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
		IF commandSuccessful THEN
			commandSuccessful := FALSE;
			_moveDone := TRUE;
			_moveDistance := FALSE;
			_state := BAG_DELIVERY_MOVE_STATES.Idle;
		END_IF														
END_CASE

//
CASE _stateFinal OF
	BAG_DELIVERY_MOVE_STATES.Idle:						
		IF _moveFinal THEN
			_stateFinal := BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode;
		END_IF
															
	BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode:				
		IF interconnect = BAG_DELIVERY_IC.EIP THEN
			IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
				TriggerPointToPointMode();
			END_IF						
			IF commandSuccessful OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Front THEN
				commandSuccessful := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.AckPointToPointMode;
			END_IF
		ELSE
			sclCommand := SCL_SO; 
			parameter1 := O2_H;
			commands.SendHostCommand := TRUE;
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff;
			END_IF
		END_IF
		
	BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff:		
		IF commandSuccessful THEN
			_stateFinal := BAG_DELIVERY_MOVE_STATES.MoveMotor;
		END_IF
		
	BAG_DELIVERY_MOVE_STATES.AckPointToPointMode:
		_delayTimer.PT := T#10MS;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			ackRequest := TRUE; // Request acknowledgment from parent class
			IF ack THEN // Parent class acknowledges this motor and sibling are ready to move
				ackRequest := FALSE;
				_delayTimer.IN := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.MoveMotor;
			END_IF
		END_IF	
															
	BAG_DELIVERY_MOVE_STATES.MoveMotor: 					
		FeedToLength();
		_stateFinal := BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor;
																			
	BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor: 		
		IF commandSuccessful AND InPosition THEN
			_delayTimer.PT := T#10MS;
			_delayTimer.IN := TRUE;
			IF _delayTimer.Q THEN
				_delayTimer.IN := FALSE;
				commandSuccessful := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.SetToTorqueMode;
			END_IF	
		END_IF
														
	BAG_DELIVERY_MOVE_STATES.SetToTorqueMode:	
		IF interconnect = BAG_DELIVERY_IC.EIP THEN
			IF placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear THEN
				TriggerTorqueMode();
			END_IF	
			IF commandSuccessful OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Front THEN
				commandSuccessful := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOn;
			END_IF
		ELSE
			TriggerTorqueMode();
			_stateFinal := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOn;
		END_IF				
																									
	BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOn:
		IF interconnect = BAG_DELIVERY_IC.EIP THEN
			_delayTimer.PT := T#10MS;
			_delayTimer.IN := TRUE;
			IF _delayTimer.Q THEN
				_moveDone := TRUE;
				_moveFinal := FALSE;
				_delayTimer.IN := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.Idle;
			END_IF
		ELSE
			IF commandSuccessful THEN
				commandSuccessful := FALSE;
				_moveDone := TRUE;
				_moveFinal := FALSE;
				_stateFinal := BAG_DELIVERY_MOVE_STATES.Idle;
			END_IF
		END_IF													
END_CASE
