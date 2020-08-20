(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_DualMotorPBar EXTENDS FB_BaseComponent IMPLEMENTS IPressureBar, IHomable
VAR_INPUT
	simulateIO : BOOL;												// Simulate all I/O for testing
	frontMotor : REFERENCE TO Axis_REF;				// The motor axis for the front (low torque) passthrough
	rearMotor : REFERENCE TO Axis_REF;					// The motor axis for the rear (high torque) passthrough
	bothMotors : REFERENCE TO Axis_REF;				// The motor axis for both passthrough motors
	closeVelo : REAL := 10;											// Passthrough Motor Velocity
	closeAccel : REAL := 100.0;											// Passthrough Motor Acceleration
	closeDecel : REAL := 100.0;											// Passthrough Motor Deceleration
	openVelo : REAL := 10;											// Passthrough Motor Velocity
	openAccel : REAL := 100.0;											// Passthrough Motor Acceleration
	openDecel : REAL := 100.0;											// Passthrough Motor Deceleration
	homeTimeoutSetting : TIME := T#20S;								// Timeout for homing attempt
	passthroughSetting : REAL := 5.5;
	jawClosedSetting : REAL := -0.2;
	jawTorqueSetting : REAL := 100.0;
	moveInDelaySetting : TIME;
	pressureBarClosedSensor : BOOL;
	pressureBarNearClosedSensor : BOOL;
	obstructionSensor : BOOL;
	openJawPB : BOOL;
	closeJawPB : BOOL;
	beginJawTestMode : BOOL;
	stopJawTestMode : BOOL;
	
END_VAR
VAR_OUTPUT
	failedToClose : FB_Fault(name := CONCAT(_prefix, 'Failed to Close'));
	failedToOpen : FB_Fault(name := CONCAT(_prefix, 'Failed to Open'));
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home'));
	pressureBarObstructed : FB_Fault(name := CONCAT(_prefix, 'Obstructed'));
	frontMotorFault : FB_Fault(name := CONCAT(_prefix, 'Front Motor Fault'));
	frontMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Front Motor Comm Fault'));
	rearMotorFault : FB_Fault(name := CONCAT(_prefix, 'Rear Motor Fault'));
	rearMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Rear Motor Comm Fault'));
	bothMotorsFault : FB_Fault(name := CONCAT(_prefix, 'Both Motors Fault'));
	actualPosition : REAL := 5.5;								// Current Passthrough Opening
	jawTestModeActive : BOOL;
	currentTestCycles : DINT;
END_VAR
VAR
	simClose : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move In')) := (minDelay := 20, maxDelay := 60);
	simOpen : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move Out')) := (minDelay := 20, maxDelay := 60);
	MC_HomeBothMotors : MC_Home;
	MC_MoveBothMotorsABS : MC_MoveAbsolute;
	MC_MoveBothMotorsABSTorque : MC_MoveAbsoluteTorqueLimited;
	MC_MoveBothMotorsINC : MC_MoveRelative;
	MC_ResetBothMotors : MC_Reset;
	MC_HaltBothMotors : MC_Halt;
	MC_ResetFrontMotor : MC_Reset;
	MC_ResetRearMotor : MC_Reset;
	_homeNow : BOOL;
	_movePassthroughNow : BOOL;
	_openNow : BOOL;
	_closeNow : BOOL;
	_isFullyClosed : BOOL;
	_isFullyOpen : BOOL;
	_IsHomed : BOOL;
	jawState : eDualMotorPBarStates;
	homeJawState : eDualMotorPbarHomingStates;
	homeTimeout : Standard.TON;
	failedToCloseTimer : Standard.TON;
	failedToOpenTimer : Standard.TON;
	moveInDelay : Standard.TON;
	jawOpenMotionFaultTimeOffset : TIME := T#500MS;
	jawCloseMotionFaultTimeOffset : TIME := T#180MS;
	bothMotorsHomed : BOOL;
	bothMotorsInPosition : BOOL;
	jawHomeClearDistance : REAL := 0.5;
	resetTimer: TON := (PT := T#2S);
	jawTestDelayTimer : Standard.TON := (PT := T#250MS);
	faultONS : FB_ONS;
END_VAR
VAR_IN_OUT
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_DualMotorPBar()
//	Description: Dual motor passthough, using a low torque motor for most movements and a high torque motor for clamping force to seal and 
//				 reverse bag			 
//	Created by: Ben Hess
//	Created Date: Wedsday, June 3rd 2020

SUPER^();

{region "Axis Setup"}
// Setup of Motion Commands for passthrough motor axis
MC_HomeBothMotors(Axis := bothMotors);
MC_MoveBothMotorsABS(Axis := bothMotors);
MC_MoveBothMotorsABSTorque(Axis := bothMotors);
MC_MoveBothMotorsINC(Axis := bothMotors);
MC_ResetBothMotors(Axis := bothMotors);
MC_ResetFrontMotor(Axis := frontMotor);
MC_ResetRearMotor(Axis := rearMotor);
MC_HaltBothMotors(Axis := bothMotors);
{endregion}
	 
{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(IN := jawState = eDualMotorPBarStates.HomeJaw, PT := homeTimeoutSetting);
// If reset of motors fails state machine must move on
resetTimer(IN := jawState = eDualMotorPBarStates.Resetting);
// Jaw move in delay	 
moveInDelay(IN := _closeNow, PT := moveInDelaySetting);	  
// Jaw test delay timer
jawTestDelayTimer();
{endregion}


{region "I/O and Fault Setup"}
// Passthrough position is based on reported motor position
actualPosition := frontMotor.ActPos;
(*
// Setup simulation of I/O and faults for testing
simClose(in := cylinder.RetractAsserted, simFeedbackFault := UN00_Globals.simFaults.pressureBarFailedToMoveIn, inputToSimulate := PressureBarClosedSensor);
simOpen(in := cylinder.ExtendAsserted, simFeedbackFault := UN00_Globals.simFaults.pressureBarFailedToMoveOut, inputToSimulate := PressureBarOpenSensor);
ObstructionSensor.simulate := PressureBarClosedSensor.simulate := PressureBarOpenSensor.simulate := simulateIO;
ObstructionSensor.simValue := NOT UN00_Globals.simFaults.pressureBarObstucted;
EnableSimulation(device := cylinder, enableSim := simulateIO);
*)

_isFullyClosed := pressureBarClosedSensor;
_isFullyOpen := TO_DINT(frontMotor.ActualPosition * 1000) <= (TO_DINT(passthroughSetting * 1000) + 10) AND TO_DINT(frontMotor.ActualPosition * 1000) >= (TO_DINT(passthroughSetting * 1000) - 10);
//_IsHomed := _isFullyOpen AND bothMotorsHomed;

// Failed to reach sensor timers
// Guestimate closing/opening time with a bit of a cushion
failedToCloseTimer(IN := jawState = eDualMotorPBarStates.ClosingJaw AND NOT _isFullyClosed,
					PT := TO_TIME((passthroughSetting / closeVelo) * 1000.0) + jawCloseMotionFaultTimeOffset,
					Q => failedToClose.faultTrigger);
failedToOpenTimer(IN := jawState = eDualMotorPBarStates.OpeningJaw AND NOT _isFullyOpen,
					PT := TO_TIME((passthroughSetting / openVelo) * 1000.0) + jawOpenMotionFaultTimeOffset,
					Q => failedToOpen.faultTrigger);

// Obstruction fault is normally closed, fail safe.  Fault if collapsable faceplate is broken anywhere outside of all the way in or all the way out
	 
IF NOT obstructionSensor AND NOT (pressureBarNearClosedSensor OR _isFullyOpen) THEN
	pressureBarObstructed.faultTrigger := TRUE;
ELSE
	pressureBarObstructed.faultTrigger := FALSE;
END_IF
	 
		  
// Trigger motor faults from drive					
IF frontMotor.Error THEN
	frontMotorFault.faultTrigger := TRUE;
ELSE 
	frontMotorFault.faultTrigger := FALSE;
END_IF

IF NOT frontMotor.CommStatus THEN
	frontMotorCommFault.faultTrigger := TRUE;
ELSE 
	frontMotorCommFault.faultTrigger := FALSE;
END_IF
 
IF rearMotor.Error THEN
	rearMotorFault.faultTrigger := TRUE;
ELSE 
	rearMotorFault.faultTrigger := FALSE;
END_IF
	 
IF NOT rearMotor.CommStatus THEN
	rearMotorCommFault.faultTrigger := TRUE;
ELSE 
	rearMotorCommFault.faultTrigger := FALSE;
END_IF
	 
IF bothMotors.Error THEN
	bothMotorsFault.faultTrigger := TRUE;
ELSE 
	bothMotorsFault.faultTrigger := FALSE;
END_IF
	 
IF homeTimeout.Q 
	OR UN00_Globals.simFaults.pressureBarfailedToHome
THEN
	failedToHome.Trigger();
END_IF
{endregion}
faultONS(CLK := pressureBarObstructed.Active OR failedToClose.Active OR bothMotorsFault.Active OR failedToOpen.Active);
IF faultONS.OSR THEN
	jawState := eDualMotorPBarStates.Faulting;
END_IF
IF stopJawTestMode THEN
	jawTestModeActive := FALSE;
END_IF

IF _reset THEN
	jawState := eDualMotorPBarStates.Reset;
	_reset := FALSE;
END_IF

_IsHomed := bothMotorsHomed AND _isFullyOpen;

bothMotorsHomed := bothMotors.HomingDone;
bothMotorsInPosition := frontMotor.TargetReached AND rearMotor.TargetReached;

CASE jawState OF
	
	eDualMotorPBarStates.Idle:
	 		// Idle State.
			jawTestDelayTimer.IN := FALSE;
			MC_ResetBothMotors.Execute := FALSE;
			IF bothMotorsHomed
				AND NOT failedToClose.Active
				AND NOT failedToOpen.Active
				AND NOT failedToHome.Active
				AND NOT pressureBarObstructed.Active
				AND NOT frontMotorFault.Active
				AND InDesiredPosition
			THEN
				_ready := TRUE;
			ELSE
				_ready := FALSE;
			END_IF
			
			IF _homeNow THEN
				_homeNow := FALSE;
				homeJawState := eDualMotorPbarHomingStates.Idle;
				jawState := eDualMotorPBarStates.HomeJaw;
			END_IF
			
			IF beginJawTestMode THEN
				jawTestModeActive := TRUE;
				currentTestCycles := 0;
				jawState := eDualMotorPBarStates.CloseJaw;
			END_IF
			
			IF _movePassthroughNow THEN
				_movePassthroughNow := FALSE;
				jawState := eDualMotorPBarStates.OpenJaw;
			ELSIF _openNow OR openJawPB OR _makeReady THEN
				openJawPB := FALSE;
				_openNow := FALSE;
				_makeReady := FALSE;
				jawState := eDualMotorPBarStates.OpenJaw;
			ELSIF (_closeNow AND moveInDelay.Q) OR closeJawPB THEN
				closeJawPB := FALSE;
				_closeNow := FALSE;
				jawState := eDualMotorPBarStates.CloseJaw;
			END_IF
								
		
		
	
	eDualMotorPBarStates.HomeJaw:	
		// Normal Homing - not factory homing.
		CASE homeJawState OF  // Begin homing sub state machine
			
// 			eDualMotorPbarHomingStates.Idle:
// 					// Move the jaw out a little bit in order to allow ZHome to happen without jamming.  Clears the rack from the rear motor
// 					MC_MoveBothMotorsINC.Distance := jawHomeClearDistance;
// 					MC_MoveBothMotorsINC.Velocity := 2;
// 					MC_MoveBothMotorsINC.Acceleration := openAccel;
// 					MC_MoveBothMotorsINC.Deceleration := openDecel;
// 					MC_MoveBothMotorsINC.Execute := TRUE;
// 					homeJawState := eDualMotorPbarHomingStates.MovingBothMotorsOutToClear;
					
			eDualMotorPbarHomingStates.Idle:
					// Z home right away
					homeJawState := eDualMotorPbarHomingStates.ZHomeBothMotors;	
			
			eDualMotorPbarHomingStates.MovingBothMotorsOutToClear: // skipping this for testing - may not be needed 
					// Wait for motors to move out to clear rack
					IF MC_MoveBothMotorsINC.Done THEN
						MC_MoveBothMotorsINC.Execute := FALSE;
						homeJawState := eDualMotorPbarHomingStates.ZHomeBothMotors;
					ELSIF MC_MoveBothMotorsINC.Error THEN
						MC_MoveBothMotorsINC.Execute := FALSE;
						failedToHome.Trigger();
						jawState := eDualMotorPBarStates.Faulting;
					END_IF
			
			eDualMotorPbarHomingStates.ZHomeBothMotors:
					// Move ZHome both motors
					MC_HomeBothMotors.Execute := TRUE;
					homeJawState := eDualMotorPbarHomingStates.ZHomingBothMotors;
					
			eDualMotorPbarHomingStates.ZHomingBothMotors:
					// When ZHomed, Move out to Open s
					IF MC_HomeBothMotors.Done THEN
						MC_HomeBothMotors.Execute := FALSE;
						homeJawState := eDualMotorPbarHomingStates.MoveMotorsToPassthrough;
					ELSIF MC_HomeBothMotors.Error THEN
						MC_HomeBothMotors.Execute := FALSE;
						failedToHome.Trigger();
						jawState := eDualMotorPBarStates.Faulting;
					END_IF
					
			eDualMotorPbarHomingStates.MoveMotorsToPassthrough:
					// Move jaw out to passthrough
					MC_MoveBothMotorsABS.Position := passthroughSetting;
					MC_MoveBothMotorsABS.Velocity := openVelo;
					MC_MoveBothMotorsABS.Acceleration := openAccel;
					MC_MoveBothMotorsABS.Deceleration := openDecel;
					MC_MoveBothMotorsABS.Execute := TRUE;
					homeJawState := eDualMotorPbarHomingStates.MovingMotorsToPassthrough;
					//jawState := eDualMotorPBarStates.OpenJaw;
					
					
			eDualMotorPbarHomingStates.MovingMotorsToPassthrough:
					// If moved out to passthrough then we are done
					IF MC_MoveBothMotorsABS.Done THEN
						MC_MoveBothMotorsABS.Execute := FALSE;
						//_IsHomed := TRUE;
						homeJawState := eDualMotorPbarHomingStates.Idle;
						jawState := eDualMotorPBarStates.Idle;
					ELSIF MC_MoveBothMotorsABS.Error THEN
						MC_MoveBothMotorsINC.Execute := FALSE;
						failedToHome.Trigger();
						jawState := eDualMotorPBarStates.Faulting;
					END_IF
		END_CASE  // End Homing sub state machine
	
	eDualMotorPBarStates.OpenJaw:	
		// Move jaw out to passthrough
		MC_MoveBothMotorsABSTorque.Position := passthroughSetting;
		MC_MoveBothMotorsABSTorque.Velocity := openVelo;
		MC_MoveBothMotorsABSTorque.Acceleration := openAccel;
		MC_MoveBothMotorsABSTorque.Deceleration := openDecel;
		MC_MoveBothMotorsABSTorque.CurrentLimit := jawTorqueSetting;
		MC_MoveBothMotorsABSTorque.Execute := TRUE;
		jawState := eDualMotorPBarStates.OpeningJaw;
		
	eDualMotorPBarStates.OpeningJaw:
		// wait for jaw to report open
		IF MC_MoveBothMotorsABSTorque.Done THEN
			MC_MoveBothMotorsABSTorque.Execute := FALSE;
			IF jawTestModeActive THEN
				jawTestDelayTimer.IN := TRUE;
				IF jawTestDelayTimer.Q THEN
					jawTestDelayTimer.IN := FALSE;
					jawState := eDualMotorPBarStates.CloseJaw;
					currentTestCycles := currentTestCycles + 1;
				END_IF
			ELSE
				jawState := eDualMotorPBarStates.Idle;
			END_IF
		ELSIF MC_MoveBothMotorsABSTorque.Error THEN
			MC_MoveBothMotorsINC.Execute := FALSE;
			failedToOpen.Trigger();
			jawState := eDualMotorPBarStates.Faulting;
		END_IF
	eDualMotorPBarStates.OpenedJaw:
		//
		
	eDualMotorPBarStates.CloseJaw:	
		// Start Moving jaw to closed position
		MC_MoveBothMotorsABSTorque.Position := jawClosedSetting;
		MC_MoveBothMotorsABSTorque.Velocity := closeVelo;
		MC_MoveBothMotorsABSTorque.Acceleration := closeAccel;
		MC_MoveBothMotorsABSTorque.Deceleration := closeDecel;
		MC_MoveBothMotorsABSTorque.CurrentLimit := jawTorqueSetting;
		MC_MoveBothMotorsABSTorque.Execute := TRUE;
		jawState := eDualMotorPBarStates.ClosingJaw;
		
	eDualMotorPBarStates.ClosingJaw:
		// Wait for jaw closed indication
		IF MC_MoveBothMotorsABSTorque.Done AND _isFullyClosed THEN
			MC_MoveBothMotorsABSTorque.Execute := FALSE;
			IF jawTestModeActive THEN
				jawTestDelayTimer.IN := TRUE;
				IF jawTestDelayTimer.Q THEN
					jawTestDelayTimer.IN := FALSE;
					jawState := eDualMotorPBarStates.OpenJaw;
				END_IF
			ELSE
				jawState := eDualMotorPBarStates.Idle;
			END_IF
			
		ELSIF MC_MoveBothMotorsABSTorque.Error THEN
			MC_MoveBothMotorsABSTorque.Execute := FALSE;
			failedToClose.Trigger();
			jawState := eDualMotorPBarStates.Faulting;
		END_IF
	eDualMotorPBarStates.ClosedJaw:
		//
		
	eDualMotorPBarStates.Faulting:
		// Free up motors on a fault
		MC_HomeBothMotors.Execute := FALSE;
		//resetPassthoughMotor.Execute := FALSE;
		MC_MoveBothMotorsABS.Execute := FALSE;
		MC_MoveBothMotorsINC.Execute := FALSE;
		MC_HaltBothMotors.Execute := FALSE;
		MC_MoveBothMotorsABSTorque.Execute := FALSE;
		MC_HaltBothMotors.Execute := TRUE;
		jawState := eDualMotorPBarStates.Faulted;
		
	eDualMotorPBarStates.Faulted:
		//
		IF MC_HaltBothMotors.Done OR  MC_HaltBothMotors.Error THEN
			MC_HaltBothMotors.Execute := FALSE;
			
		END_IF
		
	eDualMotorPBarStates.Reset:
		//  Send reset to motors if they're faulted
		
		MC_ResetBothMotors.Execute := TRUE;
		MC_ResetFrontMotor.Execute := TRUE;	
		MC_ResetRearMotor.Execute := TRUE;	
		homeJawState := eDualMotorPbarHomingStates.Idle;
		MC_HomeBothMotors.Execute := FALSE;
		//resetPassthoughMotor.Execute := FALSE;
		MC_MoveBothMotorsABS.Execute := FALSE;
		MC_MoveBothMotorsINC.Execute := FALSE;
		MC_HaltBothMotors.Execute := FALSE;
		MC_MoveBothMotorsABSTorque.Execute := FALSE;
		homeTimeout.IN := FALSE;
		_homeNow := FALSE;
		_openNow := FALSE;
		_closeNow := FALSE;
		jawTestModeActive := FALSE;
		jawState := eDualMotorPBarStates.Resetting;

	eDualMotorPBarStates.Resetting:
		//
		IF NOT bothMotors.Error OR resetTimer.Q THEN
			MC_ResetBothMotors.Execute := FALSE;
			MC_ResetFrontMotor.Execute := FALSE;	
			MC_ResetRearMotor.Execute := FALSE;
			jawState := eDualMotorPBarStates.Idle;
		END_IF
		
		
		
		

END_CASE