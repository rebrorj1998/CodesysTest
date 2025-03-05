(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedSealFlatteners_PerfBreaker EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	sealFlattenersVerticalAxis 		: FB_ThreePositionCylinder ;		//ICylinder();			
	mailerMaterial 					: MAILER_MATERIAL 	:= MAILER_MATERIAL.paper;
	perfBreakerEnable 				: BOOL ;	
	horizontalAxisAccel 			: INT 				:= 1000;    	// Acceleration for Move to Manual Setpoint and Jog Commands
    horizontalAxisDecel 			: INT 				:= 500;    		// Deceleration for Move to Manual Setpoint and Jog Commands
	manualPosSetpoint 				: REAL ;					// Position for Move to Manual Setpoint Command	
	bagFeedPosition 				: REAL ;

    testMovePB : BOOL;
    testMoveSP : REAL;
    stopPB : BOOL;

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
END_VAR
VAR
	//sealFlattenersHorizontalAxisMotor 	: FB_AppliedMotionStepServoEIPBaseQX();
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
    enableMotorizedSealFlattenersONS : FB_ONS();
	bagDropDelay : Standard.TON := (PT := T#50MS);    
	NPDPerfDelay : Standard.TON := (PT := T#5S); 

	handLoadRequested : BOOL;
	testTorque : BOOL;
	testNPDPerfBreak_Up : BOOL;
	testNPDPerfBreak_Down : BOOL;

	
	TST_OutSetpoint: BOOL := false;
	moveInCompleted: BOOL;
	moveInThreshold: REAL := 0.5;
	maxCurrentTST: DINT;
	maxSpeedTST: DINT;
	positionError : DINT;
	
	inSetpoint : REAL := 2;            		// In setpoint in inches
    moveInSpeed : INT := 2000;            	// Speed to move in in move
	moveInAccel : INT := 2000;	
	moveInDecel : INT := 2000;
	
    outSetpoint : REAL := 17.7;             // Out (sealing) setpoint in inches
    moveOutSpeed : INT := 3000;            	// Speed to move in out move
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
	 
	MSFcurrentFDBK AT %ID74 : DINT;
	MSFspeedFDBK AT %ID79 : DINT;
	MSFencoderPosition AT %ID76 : DINT;
	MSFEncPosInch : REAL;
	moveTST : BOOL;
	
	perfBreakerRetractDelayTMR : standard.TON;
	perfBreakerDelayDuration : TIME := T#5MS;

	moveInSpeedPoly: INT := 800;
	moveInSpeedPaper: INT := 3000;
	TST_PolyBagFeedSetpoint : bool := false;

	traceStartCMD: BOOL;
	positionDifBagFeed: REAL;
	moveInDelay: TON;
	_bagSealOffset: REAL := 5.0;
	moveInDelayDuration: TIME := T#100ms;
	_bagFeedOffset: REAL := 4.25;
	TST_narrowBagFeedPosition: BOOL;
	testCurrent: DINT;
	inputArray: ARRAY[0..13] OF DINT;
	testMoveAccel: INT := 2000;
	testMoveDecel: INT := 2000;
	testMoveSpeed: INT := 2000;
	testMove: INT := 1;
	TST_TorqueOut : REAL := 14.0;
	TST_TorqueIn : REAL := 2.0;
	TST_TorqueTest: BOOL;
	TST_TorqueTMR: TON;
	posReached: BOOL;
	posSetpoint: REAL;
	retryResetTMR			: TON;
	retryResetDuration		: TIME		:= T#50MS;
	atBagFeedSetpoint: BOOL;
	moveInTMR: TON;
END_VAR

VAR CONSTANT
	FEED_TO_SEAL_INSET : REAL := 1;
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
				defaultCurrentSetpoint := defaultCurrentMSF, 
				commFail := sealFlattenerMotorCommFailInput,
				isHomable := TRUE);
sealFlattenersHorizontalAxisMotor.Execute(); 
			// Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = SEAL_FLATTENER_STATES.Fault);
			//
retryResetTMR( PT := retryResetDuration );
	 
actualPosition := sealFlattenersHorizontalAxisMotor.absolutePositonInches;			
			// IF PERF BREAKER IS DISABLED, MAKE SURE IT'S NOT IN THE DOWN POSITION
IF NOT perfBreakerEnable AND perfBreaker.extendedStatus THEN
	perfBreaker.MoveUp();
END_IF

actualPosition := sealFlattenersHorizontalAxisMotor.absolutePositonInches;

			// SET UP POSITION SETPOINTS
outSetpoint := HMIData.bagWidth - _bagSealOffset;
bagHoldingSetpoint := outSetpoint;
bagFeedPosition := HMIData.bagWidth + _outSetpointOffset;
	 		// MAKE SURE SETPOINTS DO NOT EXTEND PAST THE PHYSICAL LIMIT
IF bagHoldingSetpoint > MAX_OUT_SETPOINT THEN
	bagHoldingSetpoint := MAX_OUT_SETPOINT;
END_IF

IF bagFeedPosition > MAX_OUT_SETPOINT THEN
	bagFeedPosition := MAX_OUT_SETPOINT;
END_IF	
 
IF ABS(actualPosition - outSetpoint) < positionThreshold THEN
	atOutSetpoint := TRUE;
ELSE
	atOutSetpoint := FALSE;
END_IF
IF ABS(actualPosition - bagFeedPosition) < positionThreshold THEN
	atBagFeedSetpoint := TRUE;
ELSE
	atBagFeedSetpoint := FALSE;
END_IF 	 
 
IF HMIData.bagWidth > 20.0 THEN
	inSetpoint := 3.0;
ELSE
	inSetpoint := 2.0;
END_IF

IF mailerMaterial = MAILER_MATERIAL.poly THEN
	bagFeedPosition := inSetpoint;
END_IF 
			// CHANGE OFFSETS ACCORDING TO MACHINE TYPE
IF HMIDATA.baggerModelSelection = modelSelection.Pro18_1183 THEN
	_outSetpointOffset := -3.2;
	_movingSetpointOffset := 5;
ELSIF HMIDATA.baggerModelSelection = modelSelection.Pro24_1182 THEN
	_outSetpointOffset := -2.0;
	_movingSetpointOffset := 5;
END_IF
			// SET UP BAG HOLDING CURRENT AND MOVE IN SPEED FOR DIFFERENT MAILER MATERIAL
IF mailerMaterial = MAILER_MATERIAL.poly THEN
	bagHoldingCurrentMSF := bagHoldCurrentPoly;
	moveInSpeed := moveInSpeedPoly;
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
		 manualPosSetpoint := bagFeedPosition;
		 moveToManualSetpoint := TRUE;
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
    
    SEAL_FLATTENER_STATES.Idle :                                    //If enabled move to out
                                                                    IF (enable AND HMIData.sealFlattenersInUse) AND (semiAutoModeSelected OR (autoModeSelected AND (_amMoveOut OR _amMoveToStart))) THEN
                                                                        state := SEAL_FLATTENER_STATES.MoveFlattenersOut;
                                                                        ClearCommands();
																		//traceStartCMD := TRUE;
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
																	
																	IF (enable AND HMIData.sealFlattenersInUse) AND autoModeSelected AND (_amMoveIn OR _amMoveInToBagHolding) THEN
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
																									velocity := moveOutSpeed);
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
																		state := SEAL_FLATTENER_STATES.MoveFlattenersToBagFeed;	
																		sealFlattenersVerticalAxis.Retract();  
                                                                        ClearCommands();
																	ELSIF (autoModeSelected AND _amMoveToStart) THEN
																		 state := SEAL_FLATTENER_STATES.idle;
																	     _amMoveToStart := FALSE;
                                                                    END_IF
																	
    SEAL_FLATTENER_STATES.MoveFlattenersUpAndToClearance :          // Move flatteners to clearance position
																	timeoutTimer.IN := TRUE;
                                                                    sealFlattenersHorizontalAxisMotor.MoveToPosition(position := outSetpoint,
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
																	delay.PT := T#0MS; delay.IN := TRUE;
																	IF delay.Q THEN																 																	
																		sealFlattenersHorizontalAxisMotor.MoveToPosition(position := bagFeedPosition, 
																															acceleration := horizontalAxisAccel,
																															deceleration := horizontalAxisDecel,
																															velocity := moveInSpeed);
																		posSetpoint := bagFeedPosition;  
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
                                                                       // ClearCommands();
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
																  	IF sealFlattenersHorizontalAxisMotor.CommandAcknowledged THEN
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
																	  traceStartCMD := false;
	SEAL_FLATTENER_STATES.Reset:
																  //MOVE FLATTS AND PERFBREAKER UP AND OUT TO AVOID OBSTRUCTION WITH PRESSUREBAR
																  //sealFlattenersHorizontalAxisMotor.Reset();
																  retryResetTMR.IN := TRUE;
																  perfBreaker.MoveUp();
																  sealFlattenersVerticalAxis.Retract();
																  // CHECK THAT MOTOR IS READY (RESET HAS PROPAGATED)
																  IF sealFlattenersHorizontalAxisMotor.status.motorEnabled AND NOT sealFlattenersHorizontalAxisMotor.status.alarmPresent AND NOT sealFlattenersHorizontalAxisMotor.status.driveFaulted THEN
																	  state := SEAL_FLATTENER_STATES.Idle;
																  ELSIF retryResetTMR.Q THEN
																  	  sealFlattenersHorizontalAxisMotor.Reset();
																	  retryResetTMR.IN := FALSE;
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
    testMovePB := FALSE;
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
	 
IF moveTST AND MSFcurrentFDBK > maxCurrentTST THEN
	 maxCurrentTST := MSFcurrentFDBK;
END_IF
	 
IF moveTST AND MSFspeedFDBK > maxSpeedTST THEN
	 maxSpeedTST := MSFspeedFDBK;
END_IF
positionDifBagFeed := ABS( sealFlattenersHorizontalAxisMotor.absolutePositonInches - bagFeedPosition) ;
MSFEncPosInch := -1.0 * ( TO_REAL(MSFencoderPosition) / Globals.STEPS_PER_INCH_SEAL_FLATTENER_HORIZONTAL_AXIS_MOTOR );

TST_TorqueTMR( PT := T#1S );
	 
IF TST_TorqueTest THEN
	traceStartCMD := TRUE;
	CASE testMove OF
		1:		//Move Out 2 A
			sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := TST_TorqueOut, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := 300);
			posSetpoint := TST_TorqueOut;
			testMove := testMove + 1;

		2:		//Move In 2 A
			TST_TorqueTMR.IN := TRUE;
			IF TST_TorqueTMR.Q THEN
				sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := TST_TorqueIn, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := 300);
				posSetpoint := TST_TorqueIn;													 
				testMove := testMove + 1;
				TST_TorqueTMR.IN := FALSE;
			END_IF
				 
		3:		//Move Out 1 A
			TST_TorqueTMR.IN := TRUE;			 
			IF TST_TorqueTMR.Q THEN
				sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := TST_TorqueOut, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := 200);
				posSetpoint := TST_TorqueOut;
				testMove := testMove + 1;
				TST_TorqueTMR.IN := FALSE;
			END_IF
				 
		4:		//Move In 1 A
			TST_TorqueTMR.IN := TRUE;
			IF TST_TorqueTMR.Q THEN
				sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := TST_TorqueIn, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := 200);
				posSetpoint := TST_TorqueIn;													 
				testMove := testMove + 1;
				TST_TorqueTMR.IN := FALSE;
			END_IF
				 
		5:		//Move Out .5 A
			TST_TorqueTMR.IN := TRUE;			 
			IF TST_TorqueTMR.Q THEN
				sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := TST_TorqueOut, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := 100);
				posSetpoint := TST_TorqueOut;													 
				testMove := testMove + 1;					 
				TST_TorqueTMR.IN := FALSE;
			END_IF
				 
		6:		//Move In .5 A
			TST_TorqueTMR.IN := TRUE;
			IF TST_TorqueTMR.Q THEN
				sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(position := TST_TorqueIn, 
                                              acceleration := testMoveAccel,
                                              deceleration := testMoveDecel,
                                              velocity := testMoveSpeed,
												current := 100);
				posSetpoint := TST_TorqueIn;													 
				testMove := 1;
				TST_TorqueTest := FALSE;
				TST_TorqueTMR.IN := FALSE;
				traceStartCMD := FALSE;
			END_IF
				 
	END_CASE
	
END_IF

IF PositionReached( currentPosition := sealFlattenersHorizontalAxisMotor.absolutePositonInches, positionSetpoint := posSetpoint) THEN
	posReached := TRUE;
ELSE
	posReached := FALSE;
END_IF 
	  
{endregion}