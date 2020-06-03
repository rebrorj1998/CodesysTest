(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_DualMotorPBar EXTENDS FB_BaseComponent IMPLEMENTS IPressureBar, IHomable, IPostHomeMove
VAR_INPUT
	simulateIO : BOOL;												// Simulate all I/O for testing
	frontMotor : REFERENCE TO Sharp_Motion.Axis_REF;				// The motor axis for the front (low torque) passthrough
	rearMotor : REFERENCE TO Sharp_Motion.Axis_REF;					// The motor axis for the rear (high torque) passthrough
	bothMotors : REFERENCE TO Sharp_Motion.Axis_REF;				// The motor axis for both passthrough motors
	closeVelo : REAL := 10;											// Passthrough Motor Velocity
	closeAccel : REAL := 100.0;											// Passthrough Motor Acceleration
	closeDecel : REAL := 100.0;											// Passthrough Motor Deceleration
	openVelo : REAL := 10;											// Passthrough Motor Velocity
	openAccel : REAL := 100.0;											// Passthrough Motor Acceleration
	openDecel : REAL := 100.0;											// Passthrough Motor Deceleration
	homeTimeoutSetting : TIME := T#20S;								// Timeout for homing attempt
	passthroughSetting : REAL := 5.5;
	pressureBarClosedSensor : BOOL;
	pressureBarNearClosedSensor : BOOL;
	obstructionSensor : BOOL;
END_VAR
VAR_OUTPUT
	failedToClose : FB_Fault(name := CONCAT(_prefix, 'Failed to Close'));
	failedToOpen : FB_Fault(name := CONCAT(_prefix, 'Failed to Open'));
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home'));
	pressureBarObstructed : FB_Fault(name := CONCAT(_prefix, 'Obstructed'));
	frontMotorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	frontMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	rearMotorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	rearMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	actualPassthrough : REAL := 5.5;								// Current Passthrough Opening
END_VAR
VAR
	simClose : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move In')) := (minDelay := 20, maxDelay := 60);
	simOpen : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move Out')) := (minDelay := 20, maxDelay := 60);
	MC_HomePassthrough : Sharp_Motion.MC_Home;
	MC_MoveJaw : Sharp_Motion.MC_MoveAbsolute;
	MC_MovePassthrough : Sharp_Motion.MC_MoveAbsolute;
	MC_ResetPassthoughMotor : Sharp_Motion.MC_Reset;
	MC_HaltPasstroughMotor : Sharp_Motion.MC_Halt;
	_homeNow : BOOL;
	_movePassthroughNow : BOOL;
	_isFullyClosed : BOOL;
	_isFullyOpen : BOOL;
	adjustablePassthroughState : eDualMotorPBarStates;
	homeTimeout : Standard.TON;
	movePassthroughTimeout : Standard.TON;
	failedToCloseTimer : Standard.TON;
	failedToOpenTimer : Standard.TON;
	jawMotionFaultTimeOffset : TIME := T#200MS;
	bothMotorsHomed : BOOL;
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
MC_HomePassthrough(Axis := frontMotor);
MC_MoveJaw(Axis := frontMotor);
MC_ResetPassthoughMotor(Axis := frontMotor);
MC_HaltPasstroughMotor(Axis := frontMotor);
{endregion}
	 
{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(PT := homeTimeoutSetting);
// If passthrough doesn't reach setpoint in reasonable time, error out
movePassthroughTimeout();
{endregion}


{region "I/O and Fault Setup"}
// Passthrough position is based on reported motor position
actualPassthrough := frontMotor.ActPos;
(*
// Setup simulation of I/O and faults for testing
simClose(in := cylinder.RetractAsserted, simFeedbackFault := UN00_Globals.simFaults.pressureBarFailedToMoveIn, inputToSimulate := PressureBarClosedSensor);
simOpen(in := cylinder.ExtendAsserted, simFeedbackFault := UN00_Globals.simFaults.pressureBarFailedToMoveOut, inputToSimulate := PressureBarOpenSensor);
ObstructionSensor.simulate := PressureBarClosedSensor.simulate := PressureBarOpenSensor.simulate := simulateIO;
ObstructionSensor.simValue := NOT UN00_Globals.simFaults.pressureBarObstucted;
EnableSimulation(device := cylinder, enableSim := simulateIO);
*)

_isFullyClosed := pressureBarClosedSensor;
_isFullyOpen := TO_DINT(frontMotor.ActualPosition * 1000) = TO_DINT(passthroughSetting * 1000);


// Failed to reach sensor timers
// Guestimate closing/opening time with a bit of a cushion
failedToCloseTimer(IN := adjustablePassthroughState = eDualMotorPBarStates.ClosingJaw AND NOT _isFullyClosed,
					PT := TO_TIME((passthroughSetting / closeVelo) * 1000.0) + jawMotionFaultTimeOffset,
					Q => failedToClose.faultTrigger);
failedToOpenTimer(IN := adjustablePassthroughState = eDualMotorPBarStates.OpeningJaw AND NOT _isFullyOpen,
					PT := TO_TIME((passthroughSetting / openVelo) * 1000.0) + jawMotionFaultTimeOffset,
					Q => failedToOpen.faultTrigger);

// Obstruction fault is normally closed, fail safe.  Fault if collapsable faceplate is broken anywhere outside of all the way in or all the way out
pressureBarObstructed.faultTrigger := NOT obstructionSensor AND NOT (_isFullyClosed OR _isFullyOpen);

// Trigger motor faults from drive					
IF frontMotor.Error THEN
	frontMotorFault.faultTrigger := TRUE;
	adjustablePassthroughState := eDualMotorPBarStates.Faulting ;
ELSE 
	frontMotorFault.faultTrigger := FALSE;
END_IF
	 
IF rearMotor.Error THEN
	rearMotorFault.faultTrigger := TRUE;
	adjustablePassthroughState := eDualMotorPBarStates.Faulting ;
ELSE 
	rearMotorFault.faultTrigger := FALSE;
END_IF
{endregion}

IF _reset THEN
	adjustablePassthroughState := eDualMotorPBarStates.Resetting;
	_movePassthroughNow := FALSE;
	movePassthroughTimeout.IN := FALSE;
	_reset := FALSE;
END_IF

bothMotorsHomed := frontMotor.HomingDone AND rearMotor.HomingDone;

CASE adjustablePassthroughState OF
	
	0:  // Idle State.
		MC_ResetPassthoughMotor.Execute := FALSE;
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
		
		IF _homeNow AND NOT frontMotor.HomingDone THEN
			MC_HomePassthrough.Execute := TRUE;
			OpenLowPressure();
			_homeNow := FALSE;
			adjustablePassthroughState := 1;
		ELSIF _homeNow AND frontMotor.HomingDone THEN
			_homeNow := FALSE;
		END_IF
		
		IF _movePassthroughNow AND frontMotor.HomingDone THEN
			IF InDesiredPosition THEN
				_movePassthroughNow := FALSE;
				adjustablePassthroughState := 100;				
			ELSE
				MC_MoveJaw.Position := passthroughSetting;
				MC_MoveJaw.Velocity := closeVelo;
				MC_MoveJaw.Acceleration := closeAccel;
				MC_MoveJaw.Deceleration := closeDecel;
				_movePassthroughNow := FALSE;
				OpenLowPressure();
				
				IF UN00_Globals.simFaults.failedToMovePassthrough THEN
					movePassthroughTimeout.PT := TO_TIME(((ABS(actualPassthrough - passthroughSetting) / closeVelo) * 1000) - 500) ;
				ELSE
					movePassthroughTimeout.PT := TO_TIME(((ABS(actualPassthrough - passthroughSetting) / closeVelo) * 1000) + 2000);
				END_IF
				
				MC_MoveJaw.Execute := TRUE;
				adjustablePassthroughState := 2;
			END_IF
		END_IF
	
	1:	// Homing
		homeTimeout.IN := TRUE;
		IF homeTimeout.Q 
			OR MC_HomePassthrough.Error 
			OR UN00_Globals.simFaults.pressureBarfailedToHome
		THEN
			failedToHome.Trigger();
			adjustablePassthroughState := 100;
		END_IF
		IF MC_HomePassthrough.Done THEN
			adjustablePassthroughState := 100;
		END_IF
	
	2:	// Start Moving Passthrough
		movePassthroughTimeout.IN := TRUE;
	
		IF MC_MoveJaw.Error OR movePassthroughTimeout.Q THEN
			failedToMovePassthrough.Trigger();
			MC_MoveJaw.Execute := FALSE;
			MC_HaltPasstroughMotor.Execute := TRUE;
			Exhaust();
			adjustablePassthroughState := 100;
		END_IF
		
		IF MC_MoveJaw.Done THEN
			Open();
			MC_MoveJaw.Execute := FALSE;
			adjustablePassthroughState := 100;
		END_IF
		
	100:// Cleanup
		IF frontMotor.Error OR rearMotor.Error THEN
			MC_ResetPassthoughMotor.Execute := TRUE;
		END_IF
		MC_HomePassthrough.Execute := FALSE;
		//resetPassthoughMotor.Execute := FALSE;
		MC_MoveJaw.Execute := FALSE;
		MC_HaltPasstroughMotor.Execute := FALSE;
		homeTimeout.IN := FALSE;
		movePassthroughTimeout.IN := FALSE;
		_homeNow := FALSE;
		
		adjustablePassthroughState := 0;

END_CASE