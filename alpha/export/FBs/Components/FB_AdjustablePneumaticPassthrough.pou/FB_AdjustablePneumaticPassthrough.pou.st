(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AdjustablePneumaticPassthrough EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	pressureBarEndStopMotor : IPositionableMotor;
	jogInPB : BOOL;
	jogOutPB : BOOL;
END_VAR
VAR_OUTPUT
    homeRequired : BOOL; //Homing Required
    passthroughPosition : REAL;
    state : PASSTHROUGH_SERVO_STATES := PASSTHROUGH_SERVO_STATES.Idle; //State indication of Jaw Passthrough Servo
    exhaustPressureBarRequest : BOOL; // Exhaust pressure bar request for passthrough movement
    extendPressureBarRequest : BOOL; // Extend pressure bar request for passthrough movement
END_VAR
VAR        
    passthroughSetpoint : REAL;        // Passthrough setpoint in inches
	passthroughTravel : REAL;				// Passthrough travel total
	capturePassthroughPos : REAL;
    mustMovePassthroughOut : BOOL; //Flag to tell us that the setpoint requires us to move the passthrough out
    _homeEndStop : BOOL;            // Home End Stop Command
    _movePassthrough  : BOOL;        // Move Passthrough
    _ackRequest : BOOL;                // Request Acknowledged from controller
	passthroughSettingLast : REAL;
	timerHomeDelay : TON;
	faultONS : FB_ONS;
	jogInONS : FB_ONS;
	jogOutONS : FB_ONS;
	
END_VAR
VAR_IN_OUT
	cumulativeChangeCount : DINT;
	cumulativeChangeDistance : UDINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: AdjustablePassthroughFB
//    Description:      The adjustable passthrough on the pneumatic head uses a closed loop stepper motor to 
//                    move the end stop for the jaw cylinders
//    Created by: Ben Hess
//    Created Date: Thursday, May 10, 2018
SUPER^();
jogInONS(CLK := jogInPB);
jogOutONS(CLK := jogOutPB);
//Add 2 inch offset
passthroughPosition :=  (pressureBarEndStopMotor.CurrentPosition) - HMIData.passthroughOffset;
timerHomeDelay();
faultONS(CLK := HMIData.faultActive);


//Go to idle when enabled
enableONS(CLK := enable);
IF enableONS.Q OR resetONS.Q THEN    
    state := PASSTHROUGH_SERVO_STATES.Idle;
	_movePassthrough := FALSE;
	Globals.jawMovingIn := FALSE;
	 _homeEndStop := FALSE;
	 timerHomeDelay.IN := FALSE;
	passthroughSetpoint := HMIData.passthroughSetting + HMIData.passthroughOffset ;
END_IF

IF NOT enable THEN
    state := PASSTHROUGH_SERVO_STATES.Idle;
	_movePassthrough := FALSE;
	_homeEndStop := FALSE;
END_IF

_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = PASSTHROUGH_SERVO_STATES.Fault);
IF faultONS.OSR THEN
	pressureBarEndStopMotor.Stop();
	state := PASSTHROUGH_SERVO_STATES.Idle;
END_IF

CASE state OF
    PASSTHROUGH_SERVO_STATES.Idle :                     // Go to ready state if no home required.  Otherwise go to ready if enabled. Stay in Idle if disabled.
                                                        extendPressureBarRequest := FALSE;
                                                        exhaustPressureBarRequest := FALSE;
														timerHomeDelay.IN := FALSE;
                                                        IF enable AND pressureBarEndStopMotor.HomeRequired THEN
                                                            state := PASSTHROUGH_SERVO_STATES.HomingRequired;
                                                        ELSIF enable THEN
                                                            state := PASSTHROUGH_SERVO_STATES.Ready;
                                                        END_IF
                                                        
    PASSTHROUGH_SERVO_STATES.HomingRequired :            //When Home Servo Pushbitton is pressed
														homeRequired := TRUE;
                                                        IF _homeEndStop THEN
                                                            state := PASSTHROUGH_SERVO_STATES.StartHoming;
                                                        END_IF
                                                        
    PASSTHROUGH_SERVO_STATES.StartHoming :                
                                                        // Start motor homing sequence
                                                        exhaustPressureBarRequest := TRUE;
														Globals.jawMovingIn := TRUE;
														//extendPressureBarRequest := TRUE;
                                                        IF _ackRequest THEN
															pressureBarEndStopMotor.HomeNow();
                                                            exhaustPressureBarRequest := FALSE;
															//extendPressureBarRequest := FALSE;
                                                            _ackRequest := FALSE;
                                                            state := PASSTHROUGH_SERVO_STATES.Homing;    
                                                        END_IF        

    
    PASSTHROUGH_SERVO_STATES.Homing :                    //Move on to Home Complete once finished
														
														timerHomeDelay.PT := T#200MS;
														timerHomeDelay.IN := TRUE;
														IF NOT iPassthroughHomeSensorClear THEN
															extendPressureBarRequest := TRUE;
															Globals.jawMovingIn := FALSE;
														END_IF
														
														IF _ackRequest THEN 
															extendPressureBarRequest := FALSE;
														END_IF 
														
														IF timerHomeDelay.Q THEN
															IF (NOT pressureBarEndStopMotor.HomeRequired) THEN
																state := PASSTHROUGH_SERVO_STATES.HomeComplete;
																extendPressureBarRequest := FALSE;
																_ackRequest := FALSE;
																timerHomeDelay.IN := FALSE;
                                                        	END_IF
														END_IF
                                                        
    
    PASSTHROUGH_SERVO_STATES.HomeComplete :             //Move on to Ready State once supervisor acks the cylinder request
                                                        _homeEndStop := FALSE;
														Globals.jawMovingIn := FALSE;
                                                        exhaustPressureBarRequest := TRUE;
														homeRequired := FALSE;
                                                        IF _ackRequest THEN
                                                            exhaustPressureBarRequest := FALSE;
                                                            _ackRequest := FALSE;
                                                            state := PASSTHROUGH_SERVO_STATES.Ready;    
                                                        END_IF
                                                        
    PASSTHROUGH_SERVO_STATES.MovePassthroughOut :        // Move passthrough out
                                                        extendPressureBarRequest := TRUE;
                                                        IF _ackRequest THEN
                                                            pressureBarEndStopMotor.MoveToPosition(position := (passthroughSetpoint + HMIData.passthroughOffset), 
                                                                                    acceleration := 150, 
                                                                                    deceleration := 150, 
                                                                                    velocity := 2583);
                                                            //
                                                            extendPressureBarRequest := FALSE;
                                                            _ackRequest := FALSE;
                                                            state := PASSTHROUGH_SERVO_STATES.MovingPassthroughOut;        
                                                        END_IF
                                                        

                                                    
                                                        
    PASSTHROUGH_SERVO_STATES.MovingPassthroughOut :        //Move on to Passthrough Moved Out once position reached
														timerHomeDelay.PT := T#200MS;
														timerHomeDelay.IN := TRUE;
														IF timerHomeDelay.Q THEN
															IF (REAL_TO_INT((passthroughSetpoint + HMIData.passthroughOffset)*100) = REAL_TO_INT(passthroughPosition*100)) THEN
																state := PASSTHROUGH_SERVO_STATES.PassthroughMovedOut;
																timerHomeDelay.IN := FALSE;
															END_IF
															
															IF jogOutONS.OSF THEN
																passthroughTravel := ABS(capturePassthroughPos - passthroughPosition);
																pressureBarEndStopMotor.Stop();
																Globals.passthroughChangedFromJog := TRUE;
																state := PASSTHROUGH_SERVO_STATES.PassthroughMovedOut;
															END_IF
														END_IF
    PASSTHROUGH_SERVO_STATES.PassthroughMovedOut :       
														exhaustPressureBarRequest := TRUE; 
                                                         IF _ackRequest THEN
                                                            exhaustPressureBarRequest := FALSE;
                                                            _movePassthrough := FALSE;
                                                            _ackRequest := FALSE;
															HMIData.passthroughChanges.Increment();
                                                            cumulativeChangeCount := cumulativeChangeCount + 1;
															cumulativeChangeDistance := cumulativeChangeDistance + REAL_TO_UDINT((passthroughTravel * 10));
                                                            state := PASSTHROUGH_SERVO_STATES.Ready;    
                                                        END_IF
                                                        
    PASSTHROUGH_SERVO_STATES.MovePassthroughIn :        
                                                        exhaustPressureBarRequest := TRUE;
														Globals.jawMovingIn := TRUE;
                                                        IF _ackRequest THEN
                                                            pressureBarEndStopMotor.MoveToPosition(position := (passthroughSetpoint + HMIData.passthroughOffset), 
                                                                                    acceleration := 150, 
                                                                                    deceleration := 150, 
                                                                                    velocity := 2583);
                                                            //
                                                            exhaustPressureBarRequest := FALSE;
                                                            _ackRequest := FALSE;
                                                            state := PASSTHROUGH_SERVO_STATES.MovingPassthroughIn;        
                                                        END_IF
                                                    
                                                        
    PASSTHROUGH_SERVO_STATES.MovingPassthroughIn :        //Move on to Passthrough Moved In once position reached
														timerHomeDelay.PT := T#200MS;
														timerHomeDelay.IN := TRUE;
														IF timerHomeDelay.Q THEN
															IF (REAL_TO_INT((passthroughSetpoint + HMIData.passthroughOffset)*100) = REAL_TO_INT(passthroughPosition*100)) THEN
																state := PASSTHROUGH_SERVO_STATES.PassthroughMovedIn;
																timerHomeDelay.IN := FALSE;
															END_IF
															
															IF jogInONS.OSF THEN
																passthroughTravel := ABS(capturePassthroughPos - passthroughPosition);
																pressureBarEndStopMotor.Stop();
																Globals.passthroughChangedFromJog := TRUE;
																state := PASSTHROUGH_SERVO_STATES.PassthroughMovedIn;
															END_IF
                                                        END_IF
    PASSTHROUGH_SERVO_STATES.PassthroughMovedIn :        
                                                        exhaustPressureBarRequest := TRUE;
														Globals.jawMovingIn := FALSE;
                                                        IF _ackRequest THEN
                                                            exhaustPressureBarRequest := FALSE;
                                                            _movePassthrough := FALSE;
                                                            _ackRequest := FALSE;
															HMIData.passthroughChanges.Increment();
                                                            cumulativeChangeCount := cumulativeChangeCount + 1;
															cumulativeChangeDistance := cumulativeChangeDistance + REAL_TO_UDINT((passthroughTravel * 10));
                                                            state := PASSTHROUGH_SERVO_STATES.Ready;    
                                                        END_IF
                                                        
                                                        
    PASSTHROUGH_SERVO_STATES.Ready :                    // Keep track    
                                                        IF jogInPB THEN
															passthroughSetpoint := 2.0 + HMIData.passthroughOffset;
															capturePassthroughPos := passthroughPosition;
															state := PASSTHROUGH_SERVO_STATES.MovePassthroughIn;
														ELSIF jogOutPB THEN
															passthroughSetpoint := 8.0 + HMIData.passthroughOffset;
															capturePassthroughPos := passthroughPosition;
															state := PASSTHROUGH_SERVO_STATES.MovePassthroughOut;
														ELSIF jogInONS.OSF OR jogOutONS.OSF THEN
															Globals.passthroughChangedFromJog := TRUE;
															pressureBarEndStopMotor.Stop();
														END_IF
														
                                                        IF _movePassthrough THEN
															passthroughTravel := ABS(passthroughPosition - (passthroughSetpoint + HMIData.passthroughOffset));
                                                            IF mustMovePassthroughOut THEN
                                                                state := PASSTHROUGH_SERVO_STATES.MovePassthroughOut;
                                                                ELSE state := PASSTHROUGH_SERVO_STATES.MovePassthroughIn;
                                                            END_IF
                                                        END_IF
                                                        IF _homeEndStop THEN
                                                            state := PASSTHROUGH_SERVO_STATES.StartHoming;
                                                        END_IF
    
    PASSTHROUGH_SERVO_STATES.Fault :   					pressureBarEndStopMotor.Stop();        
END_CASE