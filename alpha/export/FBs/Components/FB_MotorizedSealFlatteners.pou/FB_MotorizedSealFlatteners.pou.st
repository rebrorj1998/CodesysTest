(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedSealFlatteners EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
    {warning 'TODO: Make a struct for some of these - too many inputs'}
	sealFlattenersVerticalAxis : ICylinder();
    clearanceOffset : REAL := 2.0;        // Clearance Offset in inches
	bagFeedPosition : REAL;
    inSetpoint : REAL := 1.25;            // In setpoint in inches
    outSetpoint : REAL := 17.7;            // Out (sealing) setpoint in inches
    bagHoldingSetpoint : REAL := 17;    // Bag holding setpoint in inches            
    clearanceSpeed : INT := 3000;        // Speed to move in clearance move
    moveInSpeed : INT := 3000;            // Speed to move in in move
    moveOutSpeed : INT := 1000;            // Speed to move in out move
    moveBagHoldingSpeed : INT := 1000;    // Speed to move in bag holding move
    fingersUpSetpoint : REAL := 0;     // Fingers Up setpoint in inches
    fingersDownSetpoint : REAL := 1.1; // Fingers down setpoint in inches
    moveFingersSpeed : INT := 2000;        // Speed to move fingers
    horizontalAxisAccel : INT := 1000;    // Accel setpoint for horizontal axis
    horizontalAxisDecel : INT := 1000;    // Decel Setpoint for horizontal axis
    verticalAxisAccel : INT := 150;    // Accel setpoint for vertical axis
    verticalAxisDecel : INT := 150;    // Decel Setpoint for vertical axis
    testMovePB : BOOL;
    testMoveSP : REAL;
    stopPB : BOOL;
    startPB : BOOL;
    nextSeqPB : BOOL;
    delay : TON := (PT:= T#25MS);
	_fingersUpDelay : Standard.TON := (PT := T#50MS);
    _fingersDownDelay : Standard.TON := (PT := T#250MS);
	sealFlattenerMotorCommFailInput : BOOL;
	manualPosSetpoint : REAL;
	
END_VAR
VAR_IN_OUT
	jogIn : BOOL;
	jogOut : BOOL;
	raiseService : BOOL;
	lowerService : BOOL;
	moveToManualSetpoint : BOOL;
END_VAR
VAR_OUTPUT
    state : SEAL_FLATTENER_STATES;
	timeoutFault : BOOL;
	position : REAL;
END_VAR
VAR
	jogInONS: FB_ONS;
	jogOutONS: FB_ONS;
	jogSpeed : INT := 100;
    sealFlattenersHorizontalAxisMotor : FB_AppliedMotionStepServoEIPBaseQX();
	defaultCurrentMSF : DINT := 150;
	outCurrentMSF : DINT := 150;
	bagHoldingCurrentMSF : DINT := 110;
	timeoutTimer : Standard.TON := (PT := T#5S);
    enableMotorizedSealFlattenersONS : FB_ONS();
	bagDropDelay : Standard.TON := (PT := T#1S);    
    _amMoveOut : BOOL;                // Auto mode move out command
	_amMoveIn : BOOL;
	_amMoveToFeedToSeal : BOOL;
    _amMoveClearance : BOOL;            // Auto mode move Clearance command
    _amMoveInToBagHolding : BOOL;    // Auto mode move in then bag holding command
	_amMoveHandLoad : BOOL;			// Auto move to hand load positon command
	handLoadRequested : BOOL;
	testTorque : BOOL;
	_testEnable : BOOL;
	_testDisable : BOOL;
	_inSP : REAL;
	_inSPForFunnel : REAL := 0.25;
	inPositionONS : FB_ONS;
END_VAR
VAR CONSTANT
	FEED_TO_SEAL_INSET : REAL := 1;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block:  MotorizedSealFlattenersFB
//    Description: State machine and motor management for motorized seal flateners
//    Currently, this code requires one to use the Oriental drive with pre-programmed 
//    sequence for the horizontal axis
//    Created by: Ben Hess
//    Created Date: Friday, April 6, 2018

SUPER^();
// Temporary delay between states for testing
_fingersDownDelay();
_fingersUpDelay();
bagDropDelay(PT := TO_TIME(HMIData.bagDropTime * 1000));
delay();
jogInONS(CLK := jogIn);
jogOutONS(CLK := jogOut);

//
outSetpoint := HMIData.bagWidth + 0.2;
bagHoldingSetpoint := HMIData.bagWidth;

// Setup the vertical axis motor
sealFlattenersVerticalAxis.Execute();

//
timeoutTimer();
IF timeoutTimer.Q AND NOT bagDropDelay.IN THEN
	timeoutFault := TRUE;
END_IF

//
sealFlattenersHorizontalAxisMotor(
	ptrEIPInputs := ADR(sealFlattenerHorizontalMotorInputs),
    ptrEIPOutputs := ADR(sealFlattenerHorizontalMotorOutputs),
    stepsPerInchSetpoint := Globals.STEPS_PER_INCH_SEAL_FLATTENER_HORIZONTAL_AXIS_MOTOR,
	reversePolarity := TRUE, 
	defaultCurrentSetpoint := defaultCurrentMSF, 
	commFail := sealFlattenerMotorCommFailInput,
	isHomable := enable);
sealFlattenersHorizontalAxisMotor.Execute();
position := sealFlattenersHorizontalAxisMotor.absolutePositonInches;
// Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = SEAL_FLATTENER_STATES.Fault);

IF enableONS.Q OR resetONS.Q THEN 
	_reset := FALSE;
	timeoutFault := FALSE;
	timeoutTimer.IN := FALSE;
	bagDropDelay.IN := FALSE;
	handLoadRequested := FALSE;
	state := SEAL_FLATTENER_STATES.Idle;
	sealFlattenersHorizontalAxisMotor.Reset();
	ClearCommands();
END_IF

IF NOT enable THEN
    state := SEAL_FLATTENER_STATES.Fault;
END_IF

// Move seal flatteners out of the way when disabled
enableMotorizedSealFlattenersONS(CLK := enable);
IF enableMotorizedSealFlattenersONS.OSF THEN
	sealFlattenersVerticalAxis.Retract();
	IF (HMIData.baggerModelSelection = ModelSelection.Pro18_1174) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_1183) THEN
		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := 17.8, 
														acceleration := horizontalAxisAccel,
														deceleration := horizontalAxisDecel,
														velocity := moveOutSpeed);   
	ELSE
		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := 23.8, 
														acceleration := horizontalAxisAccel,
														deceleration := horizontalAxisDecel,
														velocity := moveOutSpeed);    
	END_IF
END_IF

// State amchine for motorized seal flatteners
CASE state OF
    
    SEAL_FLATTENER_STATES.Idle :                                    // If enabled move to out
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND _amMoveOut) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersOut;
                                                                        ClearCommands();
                                                                    END_IF
																	
																	// If enabled move to out
                                                                    IF enable AND (autoModeSelected AND _amMoveToFeedToSeal) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersInForFeedToSeal;
                                                                        ClearCommands();
                                                                    END_IF
																	
																	IF enable AND autoModeSelected AND _amMoveIn OR _amMoveInToBagHolding THEN
																		sealFlattenersVerticalAxis.Retract();
																		state := SEAL_FLATTENER_STATES.MoveFlattenersIn;
																		ClearCommands();
																	END_IF
																	
																	IF jogInONS.OSR THEN
																		sealFlattenersHorizontalAxisMotor.MoveDistance(distance := -18, 
																									acceleration := horizontalAxisAccel, 
																									deceleration := horizontalAxisDecel, 
																									velocity := jogSpeed);
																	ELSIF jogOutONS.OSR THEN
																		sealFlattenersHorizontalAxisMotor.MoveDistance(distance := 18, 
																									acceleration := horizontalAxisAccel, 
																									deceleration := horizontalAxisDecel, 
																									velocity := jogSpeed);
																	ELSIF jogInONS.OSF OR jogOutONS.OSF THEN
																		sealFlattenersHorizontalAxisMotor.Stop();
																	END_IF
																	
																	IF raiseService THEN
																		sealFlattenersVerticalAxis.Retract();  
																		raiseService := FALSE;
																	ELSIF lowerService THEN
																		sealFlattenersVerticalAxis.Extend();  
																		lowerService := FALSE;
																	END_IF
																	
																	IF moveToManualSetpoint THEN
																		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := manualPosSetpoint, 
																									acceleration := horizontalAxisAccel, 
																									deceleration := horizontalAxisDecel, 
																									velocity := moveFingersSpeed);
																		moveToManualSetpoint := FALSE;
																	END_IF
																	
																	bagDropDelay.IN := FALSE;
																	timeoutTimer.IN := FALSE;
                                                                    
    SEAL_FLATTENER_STATES.MoveFlattenersOut :                       // Move flatteners to out position
                                                                    // SealFlattenersHorizontalAxisMotor.StartOperation();
																	timeoutTimer.IN := TRUE;
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := outSetpoint, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveOutSpeed,
																														current := outCurrentMSF);                                                    
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersOut;
                                                                    
    SEAL_FLATTENER_STATES.MovingFlattenersOut :                     // 
                                                                    delay.IN := TRUE;
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND (sealFlattenersHorizontalAxisMotor.CurrentPosition >= (bagHoldingSetpoint - 1.5) OR sealFlattenersHorizontalAxisMotor.alarms.currentFoldback) THEN
																			state := SEAL_FLATTENER_STATES.MovedFlattenersOut;
                                                                        	delay.IN := FALSE; 
																		END_IF
                                                                    END_IF
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersOut :                      // Move flatteners to clearance position state
																	timeoutTimer.IN := FALSE;
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND _amMoveClearance) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersUpAndToClearance;
																		sealFlattenersVerticalAxis.Retract();  
                                                                        ClearCommands();
                                                                    END_IF
    
    SEAL_FLATTENER_STATES.MoveFlattenersUpAndToClearance :          // Move flatteners to clearance position
                                                                    //sealFlattenersHorizontalAxisMotor.NextSequence();
																	timeoutTimer.IN := TRUE;
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := (outSetpoint - clearanceOffset), 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveOutSpeed);                            
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersUpAndToClearance;    
    
    SEAL_FLATTENER_STATES.MovingFlattenersUpAndToClearance :        
																	delay.IN := TRUE;	
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.InPosition THEN
																			IF _fingersUpDelay.Q THEN
																				state := SEAL_FLATTENER_STATES.MovedFlattenersUpAndToClearance;    
                                                                        		delay.IN := FALSE;
																				_fingersUpDelay.IN := FALSE;
																			END_IF
																		END_IF
                                                                    END_IF
																	_fingersUpDelay.IN := TRUE;
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersUpAndToClearance :         // Move flatteners to up state
																	bagDropDelay.IN := TRUE;
																	IF bagDropDelay.Q THEN
																		timeoutTimer.IN := FALSE;
																		bagDropDelay.IN := FALSE;
																		state := SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed;
																	END_IF
																	
	SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed :      			// Move flatteners to out of the way of the bag for feeding
																	IF (HMIData.baggerModelSelection = ModelSelection.Pro18_1174) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_1183) THEN
																		IF (outSetpoint + clearanceOffset) <= 17.8 THEN
																			bagFeedPosition := (outSetpoint + clearanceOffset);
																		ELSE
																			bagFeedPosition := 17.8;
																		END_IF
																	ELSE
																		IF (outSetpoint + clearanceOffset) <= 23.8 THEN
																			bagFeedPosition := (outSetpoint + clearanceOffset);
																		ELSE
																			bagFeedPosition := 23.8;
																		END_IF
																	END_IF
																		
																	timeoutTimer.IN := TRUE;
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := bagFeedPosition, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveInSpeed);              
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersToBagFeed;
	
   SEAL_FLATTENER_STATES.MovingFlattenersToBagFeed :        			delay.IN := TRUE;
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.InPosition THEN
																			state := SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed;    
                                                                        	delay.IN := FALSE;
																		END_IF
                                                                    END_IF
																
	SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed:					       // Move flatteners to up state
																	timeoutTimer.IN := FALSE;
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND (_amMoveInToBagHolding OR _amMoveIn OR _amMoveHandLoad)) THEN
																		state := SEAL_FLATTENER_STATES.MoveFlattenersIn;
                                                                    END_IF
                                           
    SEAL_FLATTENER_STATES.MoveFlattenersIn :                        // Move flatteners up and in
                                                                    //sealFlattenersHorizontalAxisMotor.NextSequence(); 
																	timeoutTimer.IN := TRUE;   
																	IF HMIData.funnelFactorySelection <> FunnelSelection.NotInstalled AND HMIData.funnelInUse THEN
																		_inSP := _inSPForFunnel;
																	ELSE
																		_inSP := inSetpoint;
																	END_IF
																                                                                
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := _inSP, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveInSpeed);                                                    
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersIn;
																	
                                                                
                                                                    
    SEAL_FLATTENER_STATES.MovingFlattenersIn :                      // If we did that command well move on 
                                                                        delay.IN := TRUE;
                                                                        IF delay.Q THEN				
																				inPositionONS(CLK :=sealFlattenersHorizontalAxisMotor.InPosition);												
																				//IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.InPosition THEN
																				IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND inPositionONS.OSR THEN
																					state := SEAL_FLATTENER_STATES.MovedFlattenersIn;
																					delay.IN := FALSE;    
																				END_IF
                                                                        END_IF 
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersIn :                        // Now that we're up and in move to down and 4 corners/bag holding
																	timeoutTimer.IN := FALSE;
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND (_amMoveInToBagHolding OR _amMoveHandLoad)) THEN
                                                                        state := SEAL_FLATTENER_STATES.MovingFlattenersDown;
																		 sealFlattenersVerticalAxis.Extend();
																		IF _amMoveHandLoad THEN
																			 handLoadRequested := TRUE;
																		END_IF
                                                                        ClearCommands();
                                                                    END_IF    
																	
																	IF enable AND (autoModeSelected AND _amMoveOut) THEN
																		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := outSetpoint, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveInSpeed);                                                    
                                                                    	state := SEAL_FLATTENER_STATES.Idle;
																		ClearCommands();
																	END_IF
    
    SEAL_FLATTENER_STATES.MoveFlattenersDown :            			// Do moves for down and bag holding
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersDown;
                             
    SEAL_FLATTENER_STATES.MovingFlattenersDown :            
                                                                        //IF sealFlattenersVerticalAxis.CommandAcknowledged AND sealFlattenersVerticalAxis.InPosition THEN
                                                                       	_fingersDownDelay.IN := TRUE;
																	  	IF _fingersDownDelay.Q THEN
																			IF handLoadRequested THEN
																				state := SEAL_FLATTENER_STATES.Idle;
																				handLoadRequested := FALSE;
																			ELSE
																				state := SEAL_FLATTENER_STATES.MoveFlattenersToBagHolding;
																			END_IF
																			_fingersDownDelay.IN := FALSE;
																		END_IF 
                                                                        //END_IF 
                                                                        
	SEAL_FLATTENER_STATES.MovedFlattenersDown :

	SEAL_FLATTENER_STATES.MoveFlattenersInForFeedToSeal:
		// Do moves for down and bag holding
    	timeoutTimer.IN := TRUE;    
    	sealFlattenersHorizontalAxisMotor.MoveToPosition(
			position := bagHoldingSetpoint - FEED_TO_SEAL_INSET, 
    	    acceleration := horizontalAxisAccel,
    	    deceleration := horizontalAxisDecel,
    	    velocity := moveBagHoldingSpeed
		);                                                
    	state := SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding;
	
	SEAL_FLATTENER_STATES.MovingFlattenersInForFeedToSeal:
		delay.IN := TRUE;
        IF delay.Q THEN
		 	IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged THEN
				state := SEAL_FLATTENER_STATES.MovedFlattenersToBagHolding;
              	delay.IN := FALSE; 
			END_IF   
        END_IF 
	
	SEAL_FLATTENER_STATES.MovedFlattenersInforFeedToSeal:
    	timeoutTimer.IN := FALSE;
		state := SEAL_FLATTENER_STATES.Idle; 			
																	                             
    SEAL_FLATTENER_STATES.MoveFlattenersToBagHolding :            // Do moves for down and bag holding
                                                                  // sealFlattenersHorizontalAxisMotor.NextSequence();
                                                                  timeoutTimer.IN := TRUE;    
                                                                  sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := bagHoldingSetpoint, 
                                                                                                                  acceleration := horizontalAxisAccel,
                                                                                                                  deceleration := horizontalAxisDecel,
                                                                                                                  velocity := moveBagHoldingSpeed,
																													current := bagHoldingCurrentMSF);                                                
                                                                  state := SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding;
                                                                        
    SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding :          
																  delay.IN := TRUE;
                                                                  IF delay.Q THEN
																  	IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged THEN
																		state := SEAL_FLATTENER_STATES.MovedFlattenersToBagHolding;
                                                                        delay.IN := FALSE; 
																	END_IF   
                                                                  END_IF 
                                                                        
    SEAL_FLATTENER_STATES.MovedFlattenersToBagHolding :           
																  timeoutTimer.IN := FALSE;
																  state := SEAL_FLATTENER_STATES.Idle;
																  HMIData.motorizedSealFlattenerCycles.Increment();
                                                                  Globals.motorizedSealFlattenersCount := Globals.motorizedSealFlattenersCount + 1;
                                                                  Globals.sealFlattenerFingersCount := Globals.sealFlattenerFingersCount + 1;
END_CASE