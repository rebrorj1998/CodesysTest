(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PneuPBarWithAdjPass EXTENDS FB_BaseComponent IMPLEMENTS IPressureBar, IHomable, IPostHomeMove
VAR_INPUT
	simulateIO : BOOL;												// Simulate all I/O for testing
	passthroughMotor : REFERENCE TO Sharp_Motion.Axis_REF;			// The motor axis for the passthrough
	ptVelo : REAL := 0.5;											// Passthrough Motor Velocity
	ptAccel : REAL := 10.0;											// Passthrough Motor Acceleration
	ptDecel : REAL := 1.0;											// Passthrough Motor Deceleration
	homeTimeoutSetting : TIME := T#20S;								// Timeout for homing attempt
	passthroughSetting : REAL := 8.0;
	cylinder : ICylinder;
END_VAR
VAR_OUTPUT
	failedToClose : FB_Fault(name := CONCAT(_prefix, 'Failed to Close'));
	failedToOpen : FB_Fault(name := CONCAT(_prefix, 'Failed to Open'));
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home'));
	pressureBarObstructed : FB_Fault(name := CONCAT(_prefix, 'Obstructed'));
	motorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	failedToMovePassthrough : FB_Fault(name := CONCAT(_prefix, 'Failed to Move Passthrough'));
	actualPassthrough : REAL := 8.0;								// Current Passthrough Opening
	//CloseSolenoid : FB_PhysicalDigitalOutput(name := CONCAT(_prefix, 'Close Solenoid'));
	//OpenSolenoid : FB_PhysicalDigitalOutput(name := CONCAT(_prefix, 'Open Solenoid'));
END_VAR
VAR
	simClose : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move In')) := (minDelay := 20, maxDelay := 60);
	simOpen : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move Out')) := (minDelay := 20, maxDelay := 60);
	MC_HomePassthrough : Sharp_Motion.MC_Home;
	MC_MovePassthrough : Sharp_Motion.MC_MoveAbsolute;
	MC_ResetPassthoughMotor : Sharp_Motion.MC_Reset;
	MC_HaltPasstroughMotor : Sharp_Motion.MC_Halt;
	_homeNow : BOOL;
	_movePassthroughNow : BOOL;
	_isFullyClosed : BOOL;
	_isFullyOpen : BOOL;
	adjustablePassthroughState : INT;
	homeTimeout : Standard.TON;
	movePassthroughTimeout : Standard.TON;
	failedToCloseTimer : Standard.TON;
	failedToOpenTimer : Standard.TON;
	faultTime : TIME := T#5S;
END_VAR
VAR_IN_OUT
	PressureBarClosedSensor : FB_PhysicalDigitalInput;
	PressureBarOpenSensor : FB_PhysicalDigitalInput;
	ObstructionSensor : FB_PhysicalDigitalInput;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_PneuPBarWithAdjPass()
//	Description: Pneumatic pressure bar with adjustable passthrough - passthrough adjustment is done with motor
//				 
//	Created by: Ben Hess
//	Created Date: Tuesday, May 14th, 2019

SUPER^();

{region "Axis Setup"}
// Setup of Motion Commands for passthrough motor axis
MC_HomePassthrough(Axis := passthroughMotor);
MC_MovePassthrough(Axis := passthroughMotor);
MC_ResetPassthoughMotor(Axis := passthroughMotor);
MC_HaltPasstroughMotor(Axis := passthroughMotor);
{endregion}
	 
{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(PT := homeTimeoutSetting);
// If passthrough doesn't reach setpoint in reasonable time, error out
movePassthroughTimeout();
{endregion}


{region "I/O and Fault Setup"}
// Passthrough position is based on reported motor position
actualPassthrough := passthroughMotor.ActPos;

// Setup simulation of I/O and faults for testing
simClose(in := cylinder.RetractAsserted, simFeedbackFault := UN00_Globals.simFaults.pressureBarFailedToMoveIn, inputToSimulate := PressureBarClosedSensor);
simOpen(in := cylinder.ExtendAsserted, simFeedbackFault := UN00_Globals.simFaults.pressureBarFailedToMoveOut, inputToSimulate := PressureBarOpenSensor);
ObstructionSensor.simulate := PressureBarClosedSensor.simulate := PressureBarOpenSensor.simulate := simulateIO;
ObstructionSensor.simValue := NOT UN00_Globals.simFaults.pressureBarObstucted;
EnableSimulation(device := cylinder, enableSim := simulateIO);


_isFullyClosed := PressureBarClosedSensor.Active;
_isFullyOpen := PressureBarOpenSensor.Active;


// Failed to reach sensor timers
// Exclusively use Close solonoid for Close fail timer since Open slow/low pressure uses both solenoids
failedToCloseTimer(IN := cylinder.RetractAsserted AND NOT _isFullyClosed,
					PT := faultTime,
					Q => failedToClose.faultTrigger);
failedToOpenTimer(IN := cylinder.ExtendAsserted AND NOT _isFullyOpen,
					PT := faultTime,
					Q => failedToOpen.faultTrigger);

// Obstruction fault is normally closed, fail safe.  Fault if collapsable jaw is broken anywhere outside of all the way in or all the way out
pressureBarObstructed.faultTrigger := ObstructionSensor.IsOff AND NOT (_isFullyClosed OR _isFullyOpen)
										OR ObstructionSensor.IsOff AND (_isFullyOpen AND cylinder.RetractAsserted);   // Also fault if broken when we try to close from all the way out
IF passthroughMotor.Error THEN
	motorFault.faultTrigger := TRUE;
	adjustablePassthroughState := 0;
ELSE 
	motorFault.faultTrigger := FALSE;
END_IF
{endregion}

IF _reset THEN
	adjustablePassthroughState := 100;
	IF passthroughMotor.Error THEN
		MC_ResetPassthoughMotor.Execute := TRUE;
	END_IF
	_movePassthroughNow := FALSE;
	movePassthroughTimeout.IN := FALSE;
	_reset := FALSE;
END_IF



CASE adjustablePassthroughState OF
	
	0:  // Idle State.
		MC_ResetPassthoughMotor.Execute := FALSE;
		IF passthroughMotor.HomingDone
			AND NOT failedToClose.Active
			AND NOT failedToOpen.Active
			AND NOT failedToHome.Active
			AND NOT pressureBarObstructed.Active
			AND NOT motorFault.Active
			AND NOT failedToMovePassthrough.Active
			AND InDesiredPosition
		THEN
			_ready := TRUE;
		ELSE
			_ready := FALSE;
		END_IF
		
		IF _homeNow AND NOT passthroughMotor.HomingDone THEN
			MC_HomePassthrough.Execute := TRUE;
			OpenLowPressure();
			_homeNow := FALSE;
			adjustablePassthroughState := 1;
		ELSIF _homeNow AND passthroughMotor.HomingDone THEN
			_homeNow := FALSE;
		END_IF
		
		IF _movePassthroughNow AND passthroughMotor.HomingDone THEN
			IF InDesiredPosition THEN
				_movePassthroughNow := FALSE;
				adjustablePassthroughState := 100;				
			ELSE
				MC_MovePassthrough.Position := passthroughSetting;
				MC_MovePassthrough.Velocity := ptVelo;
				MC_MovePassthrough.Acceleration := ptAccel;
				MC_MovePassthrough.Deceleration := ptDecel;
				_movePassthroughNow := FALSE;
				OpenLowPressure();
				
				IF UN00_Globals.simFaults.failedToMovePassthrough THEN
					movePassthroughTimeout.PT := TO_TIME(((ABS(actualPassthrough - passthroughSetting) / ptVelo) * 1000) - 500) ;
				ELSE
					movePassthroughTimeout.PT := TO_TIME(((ABS(actualPassthrough - passthroughSetting) / ptVelo) * 1000) + 2000);
				END_IF
				
				MC_MovePassthrough.Execute := TRUE;
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
	
		IF MC_MovePassthrough.Error OR movePassthroughTimeout.Q THEN
			failedToMovePassthrough.Trigger();
			MC_MovePassthrough.Execute := FALSE;
			MC_HaltPasstroughMotor.Execute := TRUE;
			Exhaust();
			adjustablePassthroughState := 100;
		END_IF
		
		IF MC_MovePassthrough.Done THEN
			Open();
			MC_MovePassthrough.Execute := FALSE;
			adjustablePassthroughState := 100;
		END_IF
		
	100:// Cleanup
		MC_HomePassthrough.Execute := FALSE;
		//resetPassthoughMotor.Execute := FALSE;
		MC_MovePassthrough.Execute := FALSE;
		MC_HaltPasstroughMotor.Execute := FALSE;
		homeTimeout.IN := FALSE;
		movePassthroughTimeout.IN := FALSE;
		_homeNow := FALSE;
		
		adjustablePassthroughState := 0;

END_CASE