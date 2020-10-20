(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MotorizedSealFlattenersFB_BagFeed EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
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
    delay : TON := (PT:= T#300MS);
	fingersDownDelay : Standard.TON := (PT := T#200MS);
	
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
END_VAR
VAR
    //pressureBarMotor : FB_FestoMotor();
    //sealFlattenersVerticalAxisMotor : FB_AppliedMotionStepServoRTU();
	jogInONS: FB_ONS;
	jogOutONS: FB_ONS;
	jogSpeed : INT := 100;
    sealFlattenersHorizontalAxisMotor : FB_AppliedMotionStepServoEIPBaseQX();
	defaultCurrentMSF : DINT := 150;
	outCurrentMSF : DINT := 150;
	bagHoldingCurrentMSF : DINT := 85;
    enableMotorizedSealFlattenersONS : R_TRIG();
	bagDropDelay : Standard.TON := (PT := T#1S);    
    _amMoveOut : BOOL;                // Auto mode move out command
	_amMoveIn : BOOL;
    _amMoveClearance : BOOL;            // Auto mode move Clearance command
    _amMoveInToBagHolding : BOOL;    // Auto mode move in then bag holding command
	_amMoveHandLoad : BOOL;			// Auto move to hand load positon command
	handLoadRequested : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block:  MotorizedSealFlattenersFB
//    Description: State machine and motor management for motorized seal flateners
//    Currently, this code requires one to use the Oriental drive with pre-programmed 
//    sequence for the horizontal axis
//    Created by: Ben Hess
//    Created Date: Friday, April 6, 2018
SUPER^();
// Setup and execute 2 motor axis'

// Temporary delay between states for testing
fingersDownDelay();
bagDropDelay(PT := TO_TIME(HMIData.bagDropTime * 1000));
delay();
jogInONS(CLK := jogIn);
jogOutONS(CLK := jogOut);
IF autoModeSelected THEN
    delay.PT := T#300MS;
ELSE
    delay.PT := T#750MS;
END_IF

outSetpoint := HMIData.bagWidth + 0.2;
bagHoldingSetpoint := HMIData.bagWidth;

// Setup the vertical axis motor
sealFlattenersVerticalAxis.Execute();

// Setup the horizontal axis motor 
(*
sealFlattenersHorizontalAxisMotor(modbusInBuffer := OrientalMotorModbusRead,
                stepsPerInchSetpoint := 125,
                reversePolarity := FALSE,
                operatingCurrentDefault := 500,
                modbusCommandOutBuffer := OrientalMotorCommandWrites,
                modbusParametersOutBuffer := OrientalMotorParameterWrites,
                triggerCommandWrite => OrientalMotorTriggerCommandWrite,
                triggerParameterWrite => OrientalMotorTriggerParameterWrite);                
sealFlattenersHorizontalAxisMotor.Execute();
*)

sealFlattenersHorizontalAxisMotor(ptrEIPInputs := ADR(sealFlattenerHorizontalMotorInputs),
                ptrEIPOutputs := ADR(sealFlattenerHorizontalMotorOutputs),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_SEAL_FLATTENER_HORIZONTAL_AXIS_MOTOR,
                faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := TRUE, 
				defaultCurrentSetpoint := defaultCurrentMSF, 
				commFail := MSFMotor.eState <> IoDrvEthernetIP.AdapterState.RUNNING,
				isHomable := TRUE);
				
sealFlattenersHorizontalAxisMotor.Execute();

//Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = SEAL_FLATTENER_STATES.Fault);

enableMotorizedSealFlattenersONS(CLK := enable);
IF stopPB THEN
    sealFlattenersHorizontalAxisMotor.Stop();
    stopPB := FALSE;
END_IF

IF startPB AND semiAutoModeSelected THEN 
    //sealFlattenersHorizontalAxisMotor.StartOperation();
    startPB := FALSE;
END_IF

IF nextSeqPB THEN 
    //sealFlattenersHorizontalAxisMotor.NextSequence();
    nextSeqPB := FALSE;
END_IF

IF testMovePB THEN
    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := (testMoveSP), acceleration := 100, deceleration := 100, velocity := 600);
    testMovePB := FALSE;
END_IF

IF enableONS.Q OR resetONS.Q THEN 
    state := SEAL_FLATTENER_STATES.Idle;
	sealFlattenersHorizontalAxisMotor.Reset();
	_reset := FALSE;
	bagDropDelay.IN := FALSE;
	ClearCommands();
	handLoadRequested := FALSE;
END_IF

IF NOT enable THEN
    state := SEAL_FLATTENER_STATES.Fault;
END_IF

// State amchine for motorized seal flatteners
CASE state OF
    

    SEAL_FLATTENER_STATES.Idle :                                    //If enabled move to out
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND _amMoveOut) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersOut;
                                                                        ClearCommands();
                                                                    END_IF
																	
																	IF enable AND autoModeSelected AND _amMoveIn OR _amMoveInToBagHolding THEN
																	//IF enable AND autoModeSelected AND _amMoveIn THEN
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
																	
                                                                    
    SEAL_FLATTENER_STATES.MoveFlattenersOut :                        // Move flatteners to out position
                                                                
                                                                    //sealFlattenersHorizontalAxisMotor.StartOperation();
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := outSetpoint, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveOutSpeed,
																														current := outCurrentMSF);                                                    
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersOut;
                                                                    
                                                                    
    SEAL_FLATTENER_STATES.MovingFlattenersOut :                        // 
                                                                    delay.IN := TRUE;
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.CurrentPosition >= (bagHoldingSetpoint - 1.5) THEN
																			state := SEAL_FLATTENER_STATES.MovedFlattenersOut;
                                                                        	delay.IN := FALSE; 
																		END_IF
                                                                    END_IF
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersOut :                        // Move flatteners to clearance position state
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND _amMoveClearance) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersUpAndToClearance;
                                                                        ClearCommands();
                                                                    END_IF
    
    
    SEAL_FLATTENER_STATES.MoveFlattenersUpAndToClearance :                // Move flatteners to clearance position
                                                                    
                                                                    //sealFlattenersHorizontalAxisMotor.NextSequence();
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := (outSetpoint - clearanceOffset), 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveOutSpeed);    
                                                                   	sealFlattenersVerticalAxis.Retract();                                                       
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersUpAndToClearance;    
    
    
    
    SEAL_FLATTENER_STATES.MovingFlattenersUpAndToClearance :        delay.IN := TRUE;
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.InPosition THEN
																			state := SEAL_FLATTENER_STATES.MovedFlattenersUpAndToClearance;    
                                                                        	delay.IN := FALSE;
																		END_IF
                                                                        
                                                                    END_IF
                                                                    
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersUpAndToClearance :                // Move flatteners to up state
																	bagDropDelay.IN := TRUE;
																	IF bagDropDelay.Q THEN
																		state := SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed;
																		bagDropDelay.IN := FALSE;
																	END_IF
                                                                    
                                                                    
																	
	SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed :      			// Move flatteners to out of the way of the bag for feeding
																	IF HMIData.baggerModelSelection = ModelSelection.Pro18 THEN
																		IF (outSetpoint + clearanceOffset) <= 18.2 THEN
																			bagFeedPosition := (outSetpoint + clearanceOffset);
																		ELSE
																			bagFeedPosition := 18.2;
																		END_IF
																	ELSE
																		IF (outSetpoint + clearanceOffset) <= 23.8 THEN
																			bagFeedPosition := (outSetpoint + clearanceOffset);
																		ELSE
																			bagFeedPosition := 23.8;
																		END_IF
																	END_IF
																		
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
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND (_amMoveInToBagHolding OR _amMoveIn OR _amMoveHandLoad)) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersIn;
                                                                        //ClearCommands();
                                                                    END_IF
      

                               
                                                                    
    SEAL_FLATTENER_STATES.MoveFlattenersIn :                        // Move flatteners up and in
                                                                    //sealFlattenersHorizontalAxisMotor.NextSequence();    
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := inSetpoint, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveInSpeed);                                                    
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersIn;
                                                                    
                                                                    
    SEAL_FLATTENER_STATES.MovingFlattenersIn :                        // If we did that command well move on 
                                                                        delay.IN := TRUE;
                                                                        IF delay.Q THEN
																			IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.InPosition THEN
																				state := SEAL_FLATTENER_STATES.MovedFlattenersIn;
                                                                           		delay.IN := FALSE;    
																			END_IF
                                                                        END_IF 
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersIn :                        // Now that we're up and in move to down and 4 corners/bag holding
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND (_amMoveInToBagHolding OR _amMoveHandLoad)) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersDown;
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
    
    SEAL_FLATTENER_STATES.MoveFlattenersDown :            // Do moves for down and bag holding
                                                                        
                                                                        sealFlattenersVerticalAxis.Extend();
                                                                                                                                                                                
                                                                        state := SEAL_FLATTENER_STATES.MovingFlattenersDown;
                                                                        
    SEAL_FLATTENER_STATES.MovingFlattenersDown :            
                                                                        //IF sealFlattenersVerticalAxis.CommandAcknowledged AND sealFlattenersVerticalAxis.InPosition THEN
                                                                       	fingersDownDelay.IN := TRUE;
																	  	IF fingersDownDelay.Q THEN
																			state := SEAL_FLATTENER_STATES.MovedFlattenersDown;
																			fingersDownDelay.IN := FALSE;
																		END_IF 
																		
                                                                        //END_IF 
                                                                        
	SEAL_FLATTENER_STATES.MovedFlattenersDown :            			IF handLoadRequested THEN
																		state := SEAL_FLATTENER_STATES.Idle;
																		handLoadRequested := FALSE;
																	ELSE
																		state := SEAL_FLATTENER_STATES.MoveFlattenersToBagHolding;
																	END_IF
																	
                                                                    
                                                                    
    SEAL_FLATTENER_STATES.MoveFlattenersToBagHolding :            // Do moves for down and bag holding
                                                                        //sealFlattenersHorizontalAxisMotor.NextSequence();    
                                                                        sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := bagHoldingSetpoint, 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveBagHoldingSpeed,
																														current := bagHoldingCurrentMSF);                                                
                                                                        state := SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding;
                                                                        
    SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding :            delay.IN := TRUE;
                                                                        IF delay.Q THEN
																			IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged THEN
																				state := SEAL_FLATTENER_STATES.MovedFlattenersToBagHolding;
                                                                            	delay.IN := FALSE; 
																			END_IF   
                                                                        END_IF 
                                                                        
    SEAL_FLATTENER_STATES.MovedFlattenersToBagHolding :            state := SEAL_FLATTENER_STATES.Idle;
																		HMIData.motorizedSealFlattenerCycles.Increment();
                                                                        Globals.motorizedSealFlattenersCount := Globals.motorizedSealFlattenersCount +1;
                                                                        Globals.sealFlattenerFingersCount := Globals.sealFlattenerFingersCount +1;
    SEAL_FLATTENER_STATES.Ready :
    SEAL_FLATTENER_STATES.Fault :
END_CASE