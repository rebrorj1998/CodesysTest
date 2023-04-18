(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ClampingMechanism EXTENDS FB_BaseComponent IMPLEMENTS IClampingMechanism;
VAR_INPUT
	driveAlarm : BOOL;
	homeSensor : BOOL;
	timeFromHomeToClamp : TIME := T#500MS; // Time between starting the clamp motion to when we call it clamped.
	maximumClampingTime : TIME := T#4.8S;  // Maximum possible clamping time before drive will fault.
	maximumReverseTime : TIME := T#540MS;
END_VAR
VAR_OUTPUT
	oStartMotor : BOOL;
	oForwardMotor : BOOL;
	oResetDrive : BOOL;
	maximumClampingTimeExceeded : BOOL;
	homeSensorNotSeen : BOOL;
	reversing : BOOL;
	state : eClampingMechanismStates;	
END_VAR
VAR
	_startClamping : BOOL;
	_stopClamping : BOOL;
	_moving : BOOL;
	_cleared : BOOL;
	_clamping : BOOL;
	_resetDriveOutputPulse : FB_MonostableMultivibrator(name := 'Reset Clamp Drive Pulse');
	//Timers
	_timeFromHomeToClampTimer : TON;
	_maximumClampingTimeTimer : TON;
	_maximumReverseTimeTimer : TON;
END_VAR
VAR_IN_OUT

END_VAR
VAR CONSTANT
	DRIVE_RESET_PULSE_TIME_IN_MS : UINT := 500;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_ClampingMechanism()
//	Description: The 1195 clamping mechanism, which uses a brushless motor and gearbox to provide clamping force on the pressure bar.		 
//	Created by: Ben Hess
//	Created Date: 4/11/2023
SUPER^();

_timeFromHomeToClampTimer(PT := timeFromHomeToClamp, IN := state = eClampingMechanismStates.ClampMovingToClamp);
_maximumClampingTimeTimer(PT := maximumClampingTime, IN := state = eClampingMechanismStates.ClampMovedToClamp);
_maximumReverseTimeTimer(PT := maximumReverseTime, IN := state = eClampingMechanismStates.ClampMovingToRelease);
_resetDriveOutputPulse.DwellSetting := DRIVE_RESET_PULSE_TIME_IN_MS;
_resetDriveOutputPulse(Q => oResetDrive);
_clamping := state = eClampingMechanismStates.ClampMovedToClamp;
_moving :=  state = eClampingMechanismStates.ClampMovingToClamp
			OR state = eClampingMechanismStates.ClampMovingToRelease;
_cleared := homeSensor OR homeSensorNotSeen;
_ready := state = eClampingMechanismStates.Idle;// AND _cleared;
CASE state OF
	eClampingMechanismStates.Idle:  
		// Idle. Wait for command
		oStartMotor := FALSE;
		oForwardMotor := TRUE;
		IF _startClamping AND NOT driveAlarm THEN
			_startClamping := FALSE;
			homeSensorNotSeen := FALSE;
			state := eClampingMechanismStates.ClampMoveToClamp;
		END_IF
		
	eClampingMechanismStates.ClampMoveToClamp:
		// Start moving to clamp
		oStartMotor := TRUE;
		_moving := TRUE;
		state := eClampingMechanismStates.ClampMovingToClamp;
		
	eClampingMechanismStates.ClampMovingToClamp:	
		// Wait for timer to move to clamp positon 
		IF _timeFromHomeToClampTimer.Q THEN
			state := eClampingMechanismStates.ClampMovedToClamp;
		END_IF
	
	eClampingMechanismStates.ClampMovedToClamp:
		// Wait for command to reverse, or maximum timeout reached
		IF _stopClamping OR _maximumClampingTimeTimer.Q THEN
			_stopClamping := FALSE;
			// Flag on max clamping time exceeded
			maximumClampingTimeExceeded := _maximumClampingTimeTimer.Q;
			state := eClampingMechanismStates.ClampMoveToRelease;
		END_IF
	
	eClampingMechanismStates.ClampMoveToRelease:
		// Start moving to release 
		oForwardMotor := FALSE;
		state := eClampingMechanismStates.ClampMovingToRelease;

	eClampingMechanismStates.ClampMovingToRelease:	
		// Wait for home sensor, or maximum reverse time
		IF homeSensor OR _maximumReverseTimeTimer.Q THEN
			_stopClamping := FALSE;
			// Flag on broken sensor
			homeSensorNotSeen := _maximumReverseTimeTimer.Q;
			state := eClampingMechanismStates.ClampMovedToRelease;
		END_IF
		
	eClampingMechanismStates.ClampMovedToRelease:
		// Home. 
		state := eClampingMechanismStates.Idle;
	
	eClampingMechanismStates.Fault:
		oStartMotor := FALSE;
		oForwardMotor := FALSE;
		state := eClampingMechanismStates.Faulting;
	eClampingMechanismStates.Faulting:
	
	eClampingMechanismStates.Faulted:
	
	eClampingMechanismStates.Reset:
		// Start reset process
		oStartMotor := FALSE;
		oForwardMotor := FALSE;
		_resetDriveOutputPulse.Trigger();
		state := eClampingMechanismStates.Resetting;
		
	eClampingMechanismStates.Resetting:
		// Wait for alarm to go away
		IF NOT _resetDriveOutputPulse.Q THEN
			IF driveAlarm THEN
				state := eClampingMechanismStates.Fault;
			ELSE
				state := eClampingMechanismStates.ResetDone;
			END_IF
		END_IF
		
	eClampingMechanismStates.ResetDone:
		// Go back to idle
		state := eClampingMechanismStates.Idle;
END_CASE


IF driveAlarm THEN 
	state := eClampingMechanismStates.Fault;
END_IF