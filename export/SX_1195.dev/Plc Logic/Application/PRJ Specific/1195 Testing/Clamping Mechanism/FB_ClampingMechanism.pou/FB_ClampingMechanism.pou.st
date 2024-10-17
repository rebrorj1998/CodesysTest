(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ClampingMechanism EXTENDS FB_BaseComponent IMPLEMENTS IClampingMechanism, IHomable
VAR_INPUT
	driveAlarm : BOOL;
	homeSensor : BOOL;
	timeFromHomeToClamp : TIME := T#500MS; // Time between starting the clamp motion to when we call it clamped.
	maximumClampingTime : TIME := T#4.8S;  // Maximum possible clamping time before drive will fault.
	maximumReverseTime : TIME := T#540MS;
	jogOpenCMD : BOOL := FALSE;
	jogClosedCMD: BOOL := FALSE;
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
	_homeNow: BOOL;
	_IsHomed: BOOL;
	_releaseDelay : TIME := T#150MS;
	_startClamping : BOOL;
	_stopClamping : BOOL;
	_moving : BOOL;
	_cleared : BOOL;
	_clamping : BOOL;
	_resetDriveOutputPulse : FB_MonostableMultivibrator;
	//Timers
	_timeFromHomeToClampTimer : TON;
	_maximumClampingTimeTimer : TON;
	_maximumReverseTimeTimer : TON;
	_maximumJogTimeTimer : TON := (PT:= T#1500MS);
	
	_closingTime : TIME;
	_closingTimeHighest : TIME;
	_closingTimeLowest : TIME := T#10S;
	_releasingTime : TIME;
	_releasingTimeHighest : TIME;
	_releasingTimeLowest : TIME := T#10S;
	_closingTimeArray : ARRAY[0..1000] OF TIME;
	_closingTimeaverage : TIME;
	_closingTimeCycles : INT :=0;
	_releasingTimeArray : ARRAY[0..1000] OF TIME;
	_releasingTimeAverage : TIME;
	_releasingTimeWorkingVar : TIME;
	_releasingTimeCycles : INT :=0;
	
			//variables for the state timer
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
	state_index : INT:=0;
	clampingMechanismDriveFault : FB_Fault(name := CONCAT(_prefix, 'Drive Fault'));
	_faultONS: FB_ONS;
	_activeFault: BOOL;
	_jogOpenONS: FB_ONS;
	_jogClosedONS: FB_ONS;
	manMoving: BOOL := FALSE;
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
_jogOpenONS(CLK := jogOpenCMD);
_jogClosedONS(CLK := jogClosedCMD);
_maximumJogTimeTimer(IN:= jogOpenCMD OR jogClosedCMD);
clampingMechanismDriveFault.faultTrigger := driveAlarm;
_timeFromHomeToClampTimer(PT := timeFromHomeToClamp, IN := state = eClampingMechanismStates.ClampMovingToClamp);
_maximumClampingTimeTimer(PT := maximumClampingTime, IN := state = eClampingMechanismStates.ClampMovedToClamp);
_maximumReverseTimeTimer(PT := maximumReverseTime, IN := oStartMotor = TRUE AND oForwardMotor = FALSE);//;state = eClampingMechanismStates.ClampMovingToRelease);
_resetDriveOutputPulse.DwellSetting := DRIVE_RESET_PULSE_TIME_IN_MS;
_resetDriveOutputPulse(Q => oResetDrive,_reset := _reset);
_clamping := state = eClampingMechanismStates.ClampMovedToClamp;
_moving :=  state = eClampingMechanismStates.ClampMovingToClamp
			OR state = eClampingMechanismStates.ClampMovingToRelease;
_cleared := homeSensor ;//OR homeSensorNotSeen;
//code to add timer to track duration in states
_IsHomed := homeSensor OR _maximumReverseTimeTimer.q;
stateTimer(PT:=T#10000S);
_activeFault := clampingMechanismDriveFault.Active;
_faultONS(CLK := _activeFault AND NOT oResetDrive );
IF _faultONS.OSR THEN 
	state:= eClampingMechanismStates.Fault;
END_IF
IF clr THEN
	speedTracking:=speedTracking_mt;
	clr:=FALSE;
END_IF
IF state  = laststate THEN
	stateTimer.IN := TRUE;
ELSIF state  <> laststate THEN
	stateTimer.IN := FALSE;
	IF state =0 THEN
		count_index := count_index +1;
	END_IF
	laststate:=state;
END_IF
speedTracking[state_index][count_index] := stateTimer.ET;

IF count_index >=20 THEN
	count_index :=0;
END_IF

//End modded code
_stateString := TO_STRING(state);
_ready := state = eClampingMechanismStates.Idle AND  NOT driveAlarm AND _cleared;
CASE state OF
	eClampingMechanismStates.Idle:  
		IF jogClosedCMD AND NOT _maximumJogTimeTimer.Q THEN
			oStartMotor := TRUE;
			oForwardMotor := TRUE;
			manMoving := TRUE;
		END_IF
		IF jogOpenCMD AND NOT _maximumJogTimeTimer.Q THEN
			oStartMotor := TRUE;
			oForwardMotor := FALSE;
			manMoving := TRUE;
		END_IF
		IF  _maximumJogTimeTimer.Q OR (NOT jogClosedCMD AND NOT jogOpenCMD)  THEN
			manMoving := FALSE;
			oStartMotor := FALSE;
			oForwardMotor := TRUE;
		END_IF
		state_index := 0;
		// Idle. Wait for command
		IF NOT manMoving THEN
			oStartMotor := FALSE;
			oForwardMotor := TRUE;
		END_IF
		homeSensorNotSeen := FALSE;
		IF _homeNow OR _makeReady THEN
			state := eClampingMechanismStates.Home;
			_homeNow := FALSE;
			_makeReady := FALSE;
		END_IF
		IF _startClamping AND NOT driveAlarm THEN
			_startClamping := FALSE;
			//homeSensorNotSeen := FALSE;
			state := eClampingMechanismStates.ClampMoveToClamp;
		END_IF
		IF _stopClamping AND NOT homeSensor THEN
			state := eClampingMechanismStates.ClampMoveToRelease;
		ELSE
			_stopClamping:= FALSE;
		END_IF
	eClampingMechanismStates.Home:  
		
		IF homeSensor OR _maximumReverseTimeTimer.Q THEN
			
			state := eClampingMechanismStates.Idle;
		ELSE
			state:=eClampingMechanismStates.Homing;
		END_IF
	eClampingMechanismStates.Homing:  
		IF NOT (homeSensor OR _maximumReverseTimeTimer.Q) THEN
			oForwardMotor := FALSE;	
			oStartMotor:= TRUE;
		ELSE
			oForwardMotor := TRUE;	
			oStartMotor:= FALSE;	
			state:=eClampingMechanismStates.Idle;			
		END_IF
	
	eClampingMechanismStates.ClampMoveToClamp:
		state_index := 4;
		// Start moving to clamp
		oStartMotor := TRUE;
		oForwardMotor := TRUE;
		_moving := TRUE;
		state := eClampingMechanismStates.ClampMovingToClamp;
		
	eClampingMechanismStates.ClampMovingToClamp:	
		state_index := 1;
		// Wait for timer to move to clamp positon 
		IF _timeFromHomeToClampTimer.Q OR _stopClamping THEN
			state := eClampingMechanismStates.ClampMovedToClamp;
		END_IF
	
	eClampingMechanismStates.ClampMovedToClamp:
		state_index := 2;
		// Wait for command to reverse, or maximum timeout reached
		IF _stopClamping OR _maximumClampingTimeTimer.Q THEN
			_stopClamping := FALSE;
			// Flag on max clamping time exceeded
			maximumClampingTimeExceeded := _maximumClampingTimeTimer.Q;
			_closingTime := _maximumClampingTimeTimer.ET;
			_closingTimeArray[_closingTimeCycles] := _closingTime;
			
			IF _closingTimeCycles > 1 THEN
				_closingTimeAverage := (((_closingTimeAverage*(_closingTimeCycles-1)) + _closingTime)/(_closingTimeCycles));
			ELSE 
				_closingTimeAverage := _closingTime;
			END_IF
			_closingTimeCycles := _closingTimeCycles +1;
			state := eClampingMechanismStates.ClampMoveToRelease;
		END_IF
		
		 
	
	eClampingMechanismStates.ClampMoveToRelease:
		state_index := 5;
		// Start moving to release 
		oStartMotor := TRUE;
		oForwardMotor := FALSE;
		state := eClampingMechanismStates.ClampMovingToRelease;		
		eClampingMechanismStates.ClampMovingToRelease:	
		state_index := 3;
		// Wait for home sensor, or maximum reverse time
		IF homeSensor OR _maximumReverseTimeTimer.Q THEN
			_stopClamping := FALSE;
			// Flag on broken sensor
			homeSensorNotSeen := _maximumReverseTimeTimer.Q;
			
			_releasingTime := _maximumReverseTimeTimer.ET;
			_releasingTimeArray[_releasingTimeCycles] := _releasingTime;
			
			IF _releasingTimeCycles > 1 THEN
				_releasingTimeAverage := (((_releasingTimeAverage*(_releasingTimeCycles-1)) + _releasingTime)/(_releasingTimeCycles));
			ELSE 
				_releasingTimeAverage := _releasingTime;
			END_IF
			_releasingTimeCycles := _releasingTimeCycles +1;
			state := eClampingMechanismStates.ClampMovedToRelease;				
		END_IF
		
	eClampingMechanismStates.ClampMovedToRelease:
		state_index := 6;
		// Home. 
		_releasingTime := _maximumReverseTimeTimer.ET;
		state := eClampingMechanismStates.Idle;
	
	eClampingMechanismStates.Fault:
		state_index := 7;
		oStartMotor := FALSE;
		oForwardMotor := FALSE;
		state := eClampingMechanismStates.Faulting;
	eClampingMechanismStates.Faulting:
		state_index := 8;
		state := eClampingMechanismStates.Faulted;
	
	eClampingMechanismStates.Faulted:
		state_index := 9;
	
	eClampingMechanismStates.Reset:
		state_index := 10;
		// Start reset process
		oStartMotor := FALSE;
		oForwardMotor := FALSE;
		_resetDriveOutputPulse.Trigger();
		state := eClampingMechanismStates.Resetting;
		
	eClampingMechanismStates.Resetting:
		state_index := 11;
		// Wait for alarm to go away
		IF _resetDriveOutputPulse.Q THEN
				state := eClampingMechanismStates.ResetDone;
		END_IF
		
	eClampingMechanismStates.ResetDone:
		state_index := 12;
		// Go back to idle
		state := eClampingMechanismStates.Idle;
END_CASE


IF _closingTime > _closingTimeHighest AND _closingTime < maximumClampingTime THEN
	_closingTimeHighest := _closingTime;
END_IF

IF _closingTime < _closingTimeLowest AND _closingTime > T#0s THEN
	_closingTimeLowest := _closingTime;
END_IF

IF _releasingTime > _releasingTimeHighest AND _releasingTime < maximumReverseTime THEN	
	_releasingTimeHighest := _releasingTime;
END_IF

IF _releasingTime < _releasingTimeLowest AND _releasingTime > T#0S THEN
	_releasingTimeLowest := _releasingTime;
END_IF
