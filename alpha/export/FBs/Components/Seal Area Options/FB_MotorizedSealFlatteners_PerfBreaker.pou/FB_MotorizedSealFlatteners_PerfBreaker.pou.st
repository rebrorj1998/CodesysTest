(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedSealFlatteners_PerfBreaker EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	sealFlattenersVerticalAxis 		: ICylinder  ;		
	mailerMaterial 					: MAILER_MATERIAL 	:= MAILER_MATERIAL.paper;
	sealAreaOption					: SealAreaOptionSelectionEnum;
	perfBreakerEnable 				: BOOL ;	
	horizontalAxisAccel 			: INT 				:= 1000;    	// Acceleration for Move to Manual Setpoint and Jog Commands
    horizontalAxisDecel 			: INT 				:= 500;    		// Deceleration for Move to Manual Setpoint and Jog Commands
	manualPosSetpoint 				: REAL ;					// Position for Move to Manual Setpoint Command	
    delay : TON := (PT:= T#25MS);
	fingersDownDelay : Standard.TON := (PT := T#50MS);
	sealFlattenerMotorCommFailInput : BOOL;
END_VAR
VAR_IN_OUT
	jogIn 							: BOOL ;
	jogOut 							: BOOL ;
	raiseService 					: BOOL ;
	lowerService 					: BOOL ;
	moveToManualSetpoint 			: BOOL ;
	perfBreaker 					: PerfBreaker ;
END_VAR
VAR_OUTPUT
    state : SEAL_FLATTENER_STATES;
	actualPosition : REAL;
	timeoutFault : BOOL;
	atOutSetpoint 					: BOOL;
	atInSetpoint: BOOL;
	atBagHoldSetpoint: BOOL;
	atBagFeedSetpoint: BOOL;
	displayPos : REAL;
END_VAR
VAR
	sealFlattenersHorizontalAxisMotor 	: FB_AppliedMotionStepServoEIPBase();
    _amMoveOut 							: BOOL;                 // Auto mode move out command
	_amMoveIn 							: BOOL;					// Auto mode Move In Command
    _amMoveClearance 					: BOOL;            		// Auto mode move Clearance command
    _amMoveInToBagHolding 				: BOOL;       			// Auto mode move in then bag holding command
	_amMoveHandLoad 					: BOOL;			    	// Auto move to hand load positon command
	_amMoveToFeedToSeal 				: BOOL;
	_amMoveToStart						: BOOL;					// Auto move to start position command
	_amMoveToBagFeed 					: BOOL;					// Auto Move to Bag Feed Position
	_outSetpointOffset 					: REAL 		:= -2.5; 	// Offset value for sealing
	_movingSetpointOffset 				: REAL 		:= 5; 		// Offset value for bag holding/mailer filling position
	_bagFeedOffset						: REAL 		:= 1;
	_bagFeedPosition 					: REAL;
	testMovePB 							: BOOL;
    testMoveSP 							: REAL;
	stopPB 								: BOOL;
	MAX_OUT_SETPOINT 					: REAL 		:= 21.5;	// Maximum position due to physical constrains of mechanical assembly
	defaultCurrentMSF 					: DINT 		:= 180;		// Default Current Setpoint for Seal Flatteners
	outCurrentMSF 						: DINT 		:= 180;		// Current Setpoint for Seal Flattener Moving Out
	bagHoldingCurrentMSF 				: DINT 		:= 100;		// Current Setpoint for Bag Holding Move
	bagHoldCurrentPoly 					: DINT 		:= 100;		// Current Setpoint for Bag Holding Move for Poly material
	bagHoldCurrentPaper 				: DINT 		:= 130;		// Current Setpoint for Bag Holding Move for Paper material
	positionThreshold					: real		:= 0.1;
	
	jogInONS: FB_ONS;
	jogOutONS: FB_ONS;
	jogSpeed : INT := 100;
    timeoutTimer : Standard.TON := (PT := T#2S);
	bagDropDelay : Standard.TON := (PT := T#50MS);    
	NPDPerfDelay : Standard.TON := (PT := T#5S); 

	handLoadRequested : BOOL;
	testTorque : BOOL;

	moveInCompleted: BOOL;
	moveInThreshold: REAL := 0.5;;
	
	inSetpoint : REAL := 2;            		// In setpoint in inches
    moveInSpeed : INT := 1500;            	// Speed to move in in move
	moveInAccel : INT := 500;	
	moveInDecel : INT := 500;
	
    outSetpoint : REAL := 17.7;             // Out (sealing) setpoint in inches
    moveOutSpeed : INT := 800;            	// Speed to move in out move
	moveOutAccel : INT := 1200;	
	moveOutDecel : INT := 1200;
	moveOutTMR : TON;
	moveOutDuration : TIME;
	
    bagHoldingSetpoint : REAL := 17;    	// Bag holding setpoint in inches            
    moveBagHoldingSpeed : INT := 1000;    	// Speed to move in bag holding move    
	moveBagHoldAccel : INT := 1000;	
	moveBagHoldDecel : INT := 1500;
	moveBagHoldTMR : TON;
	moveBagHoldDuration : TIME;
	 
	moveTST : BOOL;
	
	perfBreakerRetractDelayTMR : standard.TON;
	perfBreakerDelayDuration : TIME := T#5MS;

	moveInSpeedPoly: INT := 3000;
	moveInSpeedPaper: INT := 1500;

	traceStartCMD: BOOL;
	moveInDelay: TON;
	moveInDelayDuration: TIME := T#100MS;
	testCurrent: DINT;
	testMoveAccel: INT := 2000;
	testMoveDecel: INT := 2000;
	testMoveSpeed: INT := 2000;

	posReached: BOOL;
	posSetpoint: REAL;
	retryResetTMR			: TON;
	retryResetDuration		: TIME		:= T#50MS;

	moveInTMR: TON;
	
	bagHoldTolerance: REAL := 2.5;
    clearanceOffset : REAL := 2.0;        // Clearance Offset in inches

	
END_VAR

VAR CONSTANT
	FEED_TO_SEAL_INSET : REAL := 1;
	SEAL_FLATTENER_FINGER_TO_PERF_BREAKER_OFFSET : REAL := 3.75;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block:  MotorizedSealFlattenersFB
//    Description: State Machine and motor management for Motorized Seal Flateners
//
//    Created by: Ben Hess
//    Created Date: Friday, April 6, 2018
//    Updated by: Carlos Lopez
//    Created Date: Friday, October, 2024
{region 'Set Up'}
					
SUPER^();
			// SET UP HORIZONTAL AXIS MOTOR 
sealFlattenersHorizontalAxisMotor(ptrEIPInputs := ADR(sealFlattenerHorizontalMotorInputs),
                ptrEIPOutputs := ADR(sealFlattenerHorizontalMotorOutputs),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_SEAL_FLATTENER_HORIZONTAL_AXIS_MOTOR,
				reversePolarity := TRUE, 
				positionOffset :=,
				defaultCurrentSetpoint := defaultCurrentMSF, 
				commFail := sealFlattenerMotorCommFailInput,
				isHomable := TRUE);
sealFlattenersHorizontalAxisMotor.Execute(); 

			// Set offset if we have combobreaker. Offset from outside edge of seal flattener finger to inside edge of perf breaker finger.
IF sealAreaOption = SealAreaOptionSelectionEnum.SealFlattenersWithPerfBreaker THEN
	sealFlattenersHorizontalAxisMotor.positionOffset := SEAL_FLATTENER_FINGER_TO_PERF_BREAKER_OFFSET;
ELSE
	sealFlattenersHorizontalAxisMotor.positionOffset := 0;	
END_IF
displayPos := actualPosition := sealFlattenersHorizontalAxisMotor.absolutePositonInches;
	
			// Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = SEAL_FLATTENER_STATES.Fault);
			//
retryResetTMR( PT := retryResetDuration );
	 
			// IF PERF BREAKER IS DISABLED, MAKE SURE IT'S NOT IN THE DOWN POSITION
IF NOT (mailerMaterial = MAILER_MATERIAL.paper) AND perfBreaker.extendedStatus THEN
	perfBreaker.MoveUp();
END_IF
	 
	// Setup posisitons depending on perfbreaker type
IF sealAreaOption = SealAreaOptionSelectionEnum.SealFlattenersWithPerfBreaker THEN
	inSetpoint := 5.0;
	// Set positions for perf breaker combo moves	
	IF mailerMaterial = MAILER_MATERIAL.paper THEN
		outSetpoint := HMIData.bagWidth - _outSetpointOffset;		 	 
		bagHoldingSetpoint := HMIData.bagWidth;
		_bagFeedPosition := HMIData.bagWidth + _bagFeedOffset;
		IF (HMIData.baggerModelSelection = ModelSelection.Pro18_1174) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_1183) THEN
			MAX_OUT_SETPOINT := 19;
		ELSE
			MAX_OUT_SETPOINT := 25;
		END_IF
		
	ELSIF mailerMaterial = MAILER_MATERIAL.poly THEN
		bagHoldingSetpoint := HMIData.bagWidth;
		// Clamp values
		IF (HMIData.baggerModelSelection = ModelSelection.Pro18_1174) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_1183) THEN
			IF (outSetpoint + clearanceOffset) <= 19 THEN
				_bagFeedPosition := (outSetpoint + clearanceOffset);
			ELSE
				_bagFeedPosition := MAX_OUT_SETPOINT := 19;
			END_IF
		ELSE
			IF (outSetpoint + clearanceOffset) <= 24.5 THEN
				_bagFeedPosition := (outSetpoint + clearanceOffset);
			ELSE
				_bagFeedPosition := MAX_OUT_SETPOINT := 24.5;
			END_IF
		END_IF
	END_IF
ELSE // "Regular" seal flatteners
	inSetpoint := 2.0;
	outSetpoint := HMIData.bagWidth + 0.2;
	bagHoldingSetpoint := HMIData.bagWidth;
	// Clamp values
	IF ((HMIData.baggerModelSelection = ModelSelection.Pro18_1174) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_1183)) THEN
		MAX_OUT_SETPOINT := 17.8;
		IF (outSetpoint + clearanceOffset) <= 17.8 THEN
			_bagFeedPosition := (outSetpoint + clearanceOffset);
		ELSE
			_bagFeedPosition := MAX_OUT_SETPOINT;
		END_IF
	ELSE
		MAX_OUT_SETPOINT := 23.8;
		IF (outSetpoint + clearanceOffset) <= 23.8 THEN
			_bagFeedPosition := (outSetpoint + clearanceOffset);
		ELSE
			_bagFeedPosition := MAX_OUT_SETPOINT;
		END_IF
	END_IF
END_IF
	 
// more clamping
IF outSetpoint > MAX_OUT_SETPOINT THEN
	outSetpoint := MAX_OUT_SETPOINT;
END_IF					  

IF _bagFeedPosition > MAX_OUT_SETPOINT THEN
	_bagFeedPosition := MAX_OUT_SETPOINT;
END_IF	
 
// flags for positioning
IF ABS(actualPosition - outSetpoint) < positionThreshold THEN
	atOutSetpoint := TRUE;
ELSE
	atOutSetpoint := FALSE;
END_IF
IF actualPosition - _bagFeedPosition < positionThreshold THEN
	atBagFeedSetpoint := TRUE;
ELSE
	atBagFeedSetpoint := FALSE;
END_IF 	 
	 
IF ABS(actualPosition - inSetpoint) < positionThreshold THEN
	atInSetpoint := TRUE;
ELSE
	atInSetpoint := FALSE;
END_IF 
	 
IF actualPosition > (bagHoldingSetpoint - bagHoldTolerance) THEN
	atBagHoldSetpoint := TRUE;
ELSE
	atBagHoldSetpoint := FALSE;
END_IF 

// necessary?
IF mailerMaterial = MAILER_MATERIAL.poly THEN
		//IF HMIData.passthroughPosition < 4 THEN
			//bagFeedPosition := inSetpoint;
		//ELSE	 
			//bagFeedPosition := bagFeedPosition-5;
	//	END_IF
END_IF 
			// CHANGE OFFSETS ACCORDING TO MACHINE TYPE
IF HMIData.baggerModelSelection = modelSelection.Pro18_1183 THEN
	_outSetpointOffset := 0;
	_movingSetpointOffset := 5;
ELSIF HMIData.baggerModelSelection = modelSelection.Pro24_1182 THEN
	_outSetpointOffset := 0;
	_movingSetpointOffset := 5;
END_IF
			// SET UP BAG HOLDING CURRENT AND MOVE IN SPEED FOR DIFFERENT MAILER MATERIAL
IF mailerMaterial = MAILER_MATERIAL.poly THEN
	bagHoldingCurrentMSF := bagHoldCurrentPoly;
	IF sealAreaOption = SealAreaOptionSelectionEnum.SealFlattenersWithPerfBreaker THEN
		moveInSpeed := moveInSpeedPaper;
	ELSE
		moveInSpeed := moveInSpeedPoly;
	END_IF
ELSIF mailerMaterial = MAILER_MATERIAL.paper THEN
	bagHoldingCurrentMSF := bagHoldCurrentPaper;
	moveInSpeed := moveInSpeedPaper;
END_IF
			// Temporary delay between states for testing
fingersDownDelay();
bagDropDelay(PT := TO_TIME(HMIData.bagDropTime * 1000));
moveInDelay( PT := moveInDelayDuration );
delay();
jogInONS(CLK := jogIn);
jogOutONS(CLK := jogOut);

			// Setup the vertical axis motor
sealFlattenersVerticalAxis.Execute();
{endregion}
{region "Enable, Reset, Fault"}

IF enableONS.Q OR resetONS.Q THEN 
	_reset := FALSE;
	timeoutFault := FALSE;
	bagDropDelay.IN := FALSE;
	ClearCommands();
	handLoadRequested := FALSE;
	state := SEAL_FLATTENER_STATES.Reset;
END_IF

IF enable AND NOT HMIData.sealFlattenersInUse THEN
	//state := SEAL_FLATTENER_STATES.Idle;
	IF NOT sealFlattenersHorizontalAxisMotor.HomeRequired AND NOT atBagFeedSetpoint AND (enableONS.Q OR resetONS.Q) THEN
		 manualPosSetpoint := _bagFeedPosition;
		// moveToManualSetpoint := TRUE;
	END_IF
END_IF
	 
timeoutTimer();
	 
IF timeoutTimer.Q AND bagDropDelay.IN = FALSE THEN
	timeoutFault := TRUE;
END_IF
perfBreakerRetractDelayTMR( PT := perfBreakerDelayDuration);  
{endregion} 
{region "State Machine"}
			// State amchine for motorized seal flatteners
CASE state OF
    
    SEAL_FLATTENER_STATES.Idle :                                    	//If enabled move to when requested
                                                                    IF (enable AND HMIData.sealFlattenersInUse) AND (semiAutoModeSelected OR (autoModeSelected AND (_amMoveOut OR _amMoveToStart))) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersOut;
                                                                        ClearCommands();
                                                                    END_IF
																		 
																		// If enabled move to feed to seal position
                                                                    IF enable AND (autoModeSelected AND _amMoveToFeedToSeal) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersInForFeedToSeal;
                                                                        ClearCommands();
                                                                    END_IF
																	
																	(*IF enable AND autoModeSelected AND _amMoveIn OR _amMoveInToBagHolding THEN
																		sealFlattenersVerticalAxis.Retract();
																		state := SEAL_FLATTENER_STATES.MoveFlattenersIn;
																		ClearCommands();
																	END_IF*)
																		 
																			  //above two IF statements inserted during merge of Carlos' paper work
																	
																	IF enable AND NOT HMIData.sealFlattenersInUse AND _amMoveToBagFeed THEN
																		state := SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed;
																		ClearCommands();	 
                                                                    END_IF
																	
																	IF HMIData.sealFlattenersInUse AND (semiAutoModeSelected OR (autoModeSelected AND _amMoveOut)) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersOut;
                                                                        ClearCommands();
																	//IF enable AND autoModeSelected AND _amMoveIn THEN
                                                                    END_IF
																	
																	IF (enable AND HMIData.sealFlattenersInUse) AND autoModeSelected AND (_amMoveIn (*OR _amMoveInToBagHolding*)) THEN
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
																		sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := manualPosSetpoint, 
																									acceleration := horizontalAxisAccel, 
																									deceleration := horizontalAxisDecel, 
																									velocity := moveOutSpeed,
																									current := 100);
																		moveToManualSetpoint := FALSE;
																	END_IF
																	
																	bagDropDelay.IN := FALSE;
																	timeoutTimer.IN := FALSE;
                                                                    
    SEAL_FLATTENER_STATES.MoveFlattenersOut :                       // Move flatteners to out position
																	timeoutTimer.IN := TRUE;																	
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := (outSetpoint), 
                                                                                                                        acceleration := moveOutAccel,
                                                                                                                        deceleration := moveOutDecel,
                                                                                                                        velocity := moveOutSpeed,
																														current := outCurrentMSF);
																	posSetpoint := outSetpoint;                                                   
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersOut;
                                                                    
    SEAL_FLATTENER_STATES.MovingFlattenersOut :                     // 
                                                                    delay.IN := TRUE;
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND (sealFlattenersHorizontalAxisMotor.absolutePositonInches >= (outSetpoint - _movingSetpointOffset) OR sealFlattenersHorizontalAxisMotor.alarms.currentFoldback) THEN
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
																	ELSIF (autoModeSelected AND _amMoveToStart) THEN
																		 state := SEAL_FLATTENER_STATES.Idle;
																	     _amMoveToStart := FALSE;
                                                                    END_IF
																	
    SEAL_FLATTENER_STATES.MoveFlattenersUpAndToClearance :          // Move flatteners to clearance position
																	timeoutTimer.IN := TRUE;
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := outSetpoint - clearanceOffset,
                                                                                                                     acceleration := horizontalAxisAccel,
                                                                                                                     deceleration := horizontalAxisDecel,
                                                                                                                     velocity := moveOutSpeed);
																	posSetpoint := outSetpoint;                            
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersUpAndToClearance;    
    
    SEAL_FLATTENER_STATES.MovingFlattenersUpAndToClearance :        
																	delay.IN := TRUE;	
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.status.inPosition
																		(*posReached*)
																		THEN
																			IF fingersDownDelay.Q THEN
																				state := SEAL_FLATTENER_STATES.MovedFlattenersUpAndToClearance;    
                                                                        		delay.IN := FALSE;
																				fingersDownDelay.IN := FALSE;
																			END_IF
																		END_IF
                                                                    END_IF
																	fingersDownDelay.IN := TRUE;
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersUpAndToClearance :         // Move flatteners to up state
																	bagDropDelay.IN := TRUE;
																	IF bagDropDelay.Q THEN
																		timeoutTimer.IN := FALSE;
																		bagDropDelay.IN := FALSE;
																		state := SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed;
																	END_IF
																	
	SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed :      			// Move flatteners to out of the way of the bag for feeding																		
																	timeoutTimer.IN := TRUE;
																	delay.PT := T#50MS; delay.IN := TRUE;
																	IF delay.Q THEN																 																	
																		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := _bagFeedPosition, 
																															acceleration := horizontalAxisAccel,
																															deceleration := horizontalAxisDecel,
																															velocity := moveInSpeed);
																		posSetpoint := _bagFeedPosition;  
																		state := SEAL_FLATTENER_STATES.MovingFlattenersToBagFeed;
																		delay.IN := FALSE;             
																	END_IF
   SEAL_FLATTENER_STATES.MovingFlattenersToBagFeed :        		
																	delay.IN := TRUE;
                                                                    IF delay.Q THEN
																		IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND sealFlattenersHorizontalAxisMotor.status.inPosition
																		(*posReached*) 
																		THEN
																			state := SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed;    
                                                                        	delay.IN := FALSE;
																		END_IF
                                                                    END_IF															 
																
	SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed:					       // Move flatteners to up state
																	timeoutTimer.IN := FALSE;

                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND (_amMoveInToBagHolding OR _amMoveIn OR _amMoveHandLoad)) THEN
																		state := SEAL_FLATTENER_STATES.MoveFlattenersIn;
																		ClearCommands();
                                                                    END_IF
																	IF enable AND _amMoveToBagFeed THEN
																		 state := SEAL_FLATTENER_STATES.Idle;
																		 _amMoveToBagFeed := FALSE;
																	END_IF
                                
    SEAL_FLATTENER_STATES.MoveFlattenersIn :                        // Move flatteners up and in                                                                    																
																	moveInDelay.IN := TRUE;
																	IF moveInDelay.Q THEN
																		timeoutTimer.IN := FALSE;
																		moveInDelay.IN := FALSE;
																		NPDPerfDelay.IN := FALSE;																																	
																		IF perfBreakerEnable THEN
																			perfBreaker.MoveUp();			//CARLOS								
																			perfBreakerRetractDelayTMR.IN := TRUE;
																		END_IF
																		moveInTMR.IN := TRUE;				//CARLOS
 																		moveBagHoldTMR.IN := TRUE;
																			 
                                                                    	IF perfBreakerRetractDelayTMR.Q OR NOT perfBreakerEnable THEN
																			sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := inSetpoint, 
                                                                                                                        acceleration := moveInAccel,
                                                                                                                        deceleration := moveInDecel,
                                                                                                                        velocity := moveInSpeed,
																														current := defaultCurrentMSF);
																			posSetpoint := inSetpoint;																															 
                                                    
                                                                    		state := SEAL_FLATTENER_STATES.MovingFlattenersIn;
																			perfBreakerRetractDelayTMR.IN := FALSE;
																			timeoutTimer.IN := TRUE;
																		END_IF
                                                                    END_IF
																	bagDropDelay.PT := T#1S;
                                                                    
    SEAL_FLATTENER_STATES.MovingFlattenersIn :                      // If we did that command well move on
																	ClearCommands(); 
                                                                        delay.IN := TRUE;
                                                                        IF delay.Q THEN
																			IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND ((sealFlattenersHorizontalAxisMotor.Status.InPosition (*posReached*) AND NOT moveTST)
																			 OR (moveTST AND moveInCompleted)) THEN
																				state := SEAL_FLATTENER_STATES.MovedFlattenersIn;
                                                                           		delay.IN := FALSE;    
																			END_IF
                                                                        END_IF 
                                                                    
    SEAL_FLATTENER_STATES.MovedFlattenersIn :                        // Now that we're up and in move to down and 4 corners/bag holding
																	timeoutTimer.IN := FALSE;
                                                                    IF enable AND semiAutoModeSelected OR (autoModeSelected AND (_amMoveInToBagHolding OR _amMoveHandLoad)) THEN
                                                                        sealFlattenersVerticalAxis.Extend();
																		state := SEAL_FLATTENER_STATES.MovingFlattenersDown; 
																			IF _amMoveHandLoad THEN
																			 handLoadRequested := TRUE;
																		END_IF
                                                                       ClearCommands();
                                                                    END_IF   
																		 
																	
                                                                                                                                        		  
																	
																	IF enable AND (autoModeSelected AND _amMoveOut) THEN
																		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := (outSetpoint  + 0), 
                                                                                                                        acceleration := horizontalAxisAccel,
                                                                                                                        deceleration := horizontalAxisDecel,
                                                                                                                        velocity := moveInSpeed);
																		posSetpoint := outSetpoint;                                                    
                                                                    	state := SEAL_FLATTENER_STATES.Idle;
																		ClearCommands();
																			 
																	END_IF
    
    SEAL_FLATTENER_STATES.MoveFlattenersDown :            			// Do moves for down and bag holding
                                                                    state := SEAL_FLATTENER_STATES.MovingFlattenersDown;
                             
    SEAL_FLATTENER_STATES.MovingFlattenersDown :            
																	//IF sealFlattenersVerticalAxis.CommandAcknowledged AND sealFlattenersVerticalAxis.Status.InPosition THEN
																	fingersDownDelay.IN := TRUE;
																	IF fingersDownDelay.Q THEN
																		IF handLoadRequested THEN
																			state := SEAL_FLATTENER_STATES.Idle;
																			handLoadRequested := FALSE;
																		ELSE
																			state := SEAL_FLATTENER_STATES.MoveFlattenersToBagHolding;
																		END_IF
																		fingersDownDelay.IN := FALSE;
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
		 														  //traceStartCMD := true;
                                                                  timeoutTimer.IN := TRUE;
																  moveOutTMR.IN := TRUE;    
                                                                  sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := bagHoldingSetpoint (*- _movingSetpointOffset*), 
                                                                                                                  acceleration := moveBagHoldAccel,
                                                                                                                  deceleration := moveBagHoldDecel,
                                                                                                                  velocity := moveBagHoldingSpeed,
																													current := bagHoldingCurrentMSF);
																  posSetpoint := bagHoldingSetpoint;                                                
                                                                  state := SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding;
                                                                        
    SEAL_FLATTENER_STATES.MovingFlattenersToBagHolding :          
																  delay.IN := TRUE;
                                                                  IF delay.Q THEN
																  	IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged AND (actualPosition > 6.0) THEN
																		moveBagHoldDuration :=	moveBagHoldTMR.ET;		//CARLOS
																		moveBagHoldTMR.IN := FALSE;
																		moveOutDuration := moveOutTMR.ET;
																		moveOutTMR.IN := FALSE;	 
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
																	  traceStartCMD := FALSE;																		   
																			
	SEAL_FLATTENER_STATES.Reset:
																  //MOVE FLATTS AND PERFBREAKER UP AND OUT TO AVOID OBSTRUCTION WITH PRESSUREBAR
																  //sealFlattenersHorizontalAxisMotor.Reset();
																  retryResetTMR.IN := TRUE;
																  perfBreaker.MoveUp();
																  //sealFlattenersVerticalAxis.Retract();
																  // CHECK THAT MOTOR IS READY (RESET HAS PROPAGATED)
																  IF sealFlattenersHorizontalAxisMotor.status.motorEnabled AND NOT sealFlattenersHorizontalAxisMotor.status.alarmPresent AND NOT sealFlattenersHorizontalAxisMotor.status.driveFaulted THEN
																	  state := SEAL_FLATTENER_STATES.Idle;
																  ELSIF retryResetTMR.Q THEN
																  	  sealFlattenersHorizontalAxisMotor.Reset();
																	  retryResetTMR.IN := FALSE;
																	  state := SEAL_FLATTENER_STATES.Idle;
																  END_IF		 

END_CASE
	 
{endregion}
	 
{region "Testing"}

IF stopPB THEN
    sealFlattenersHorizontalAxisMotor.Stop();
    stopPB := FALSE;
END_IF

IF testTorque THEN
	sealFlattenersHorizontalAxisMotor.MoveDistanceTorque(-0.5, 100, 100, 100, 20);
	testTorque := FALSE;
END_IF
	 
IF testMovePB THEN
	traceStartCMD := TRUE;
	sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := testMoveSP, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := testCurrent);
	moveInTMR.IN := TRUE;
END_IF

moveInTMR( PT := T#2S );
IF moveInTMR.Q THEN
	 traceStartCMD := FALSE;
	 moveInTMR.IN := FALSE;
END_IF
moveOutTMR( PT := T#2S );
moveBagHoldTMR( PT := T#2S );
moveInCompleted := ABS(inSetpoint - sealFlattenersHorizontalAxisMotor.absolutePositonInches) < moveInThreshold;

IF PositionReached( currentPosition := sealFlattenersHorizontalAxisMotor.absolutePositonInches, positionSetpoint := posSetpoint) THEN
	posReached := TRUE;
ELSE
	posReached := FALSE;
END_IF 
	  
{endregion}