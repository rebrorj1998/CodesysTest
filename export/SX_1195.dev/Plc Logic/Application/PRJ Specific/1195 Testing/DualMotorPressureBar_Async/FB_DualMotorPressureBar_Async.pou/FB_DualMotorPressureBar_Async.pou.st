(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_DualMotorPressureBar_Async EXTENDS FB_BaseComponent IMPLEMENTS IPressureBar, IHomable
VAR_INPUT
	simulateIO : BOOL;								// Simulate all I/O for testing
	frontMotor : REFERENCE TO FB_AZDKAxis;				// The motor axis for the front (low torque) passthrough
	clampingMechanism : IClampingMechanism;			// Clamping Mechanism
	closeProfile : sctMotionProfile;				// Passthrough Close Profile
	openProfile : sctMotionProfile;					// Passthrough Open Profile
	pushProfile : sctMotionProfile;
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
	pressureBarObstructed : FB_Fault(name := CONCAT(_prefix, 'Obstructed'));
	frontMotorFault : FB_Fault(name := CONCAT(_prefix, 'Front Motor Fault'));
	frontMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Front Motor Comm Fault'));
	failedToClose : FB_Fault(name := CONCAT(_prefix, 'Failed to Close'));
	failedToOpen : FB_Fault(name := CONCAT(_prefix, 'Failed to Open'));
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home '));
	actualPositionInInches : REAL;
	jawTestModeActive : BOOL;
	currentTestCycles : DINT;
	state : eDualMotorPressureBar_AsyncStates;
END_VAR
VAR
// 	simClose : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move In')) := (minDelay := 20, maxDelay := 60);
// 	simOpen : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Move Out')) := (minDelay := 20, maxDelay := 60);
	MC_HomeFrontMotor : MC_Home;
	MC_PowerUpFrontJawMotor : MC_Power;
	MC_MoveFrontMotorABS : MC_MoveAbsolute;
	MC_MoveFrontMotorPush : MC_MoveAbsolutePush;
	MC_ResetFrontMotor : MC_Reset;
	MC_HaltFrontMotor : MC_Halt;
	_movePassthroughNow : BOOL;
	_homeNow : BOOL;
	_openNow : BOOL;
	_closeNow : BOOL;
	_isHomed : BOOL;
	_isFullyOpen : BOOL;
	_isFullyClosed : BOOL;
	_failedToCloseTimer : Standard.TON;
	_failedToOpenTimer : Standard.TON;
	_moveInDelay : Standard.TON;
	_jawOpenMotionFaultTimeOffset : TIME := T#3S;
	_jawCloseMotionFaultTimeOffset : TIME := T#3S;
	_resetTimer: Standard.TON := (PT := T#2S);
	_timeoutTimer : Standard.TON := (PT := T#6S);
	_jawTestDelayTimer : Standard.TON := (PT := T#250MS);
	_faultONS : FB_ONS;
	_startClampingONS : FB_ONS;
	_startClampingPosition : REAL := 4.0;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_DualMotorPressureBar_Async()
//	Description: Dual motor passthough, using a low torque positionable motor for most movements and a high torque brushless motor for clamping force to seal and 
//				 reverse bag			 
//	Created by: Ben Hess
//	Created Date: 4/11/2023

SUPER^();


// Setup of Motion Commands for passthrough motor axis
MC_HomeFrontMotor(axis := frontMotor);
MC_MoveFrontMotorABS(axis := frontMotor);
MC_MoveFrontMotorPush(axis := frontMotor);
MC_ResetFrontMotor(axis := frontMotor);
MC_HaltFrontMotor(axis := frontMotor);
MC_PowerUpFrontJawMotor(
	enable := F_EtherCatSlaveCommsRunning(state := AZD4A_KED.wState) AND NOT (state = eDualMotorPressureBar_AsyncStates.Resetting), 
	axis := frontMotor
);
// If reset of motors fails state machine must move on
_resetTimer(IN := state = eDualMotorPressureBar_AsyncStates.Resetting);

// Jaw move in delay	 
_moveInDelay(IN := _closeNow, PT := moveInDelaySetting);	
  
// Jaw test delay timer
_jawTestDelayTimer();
	 
// Passthrough position is based on reported motor position

actualPositionInInches := frontMotor.actualPositonInInches;
	 
//_isFullyClosed := actualPositionInInches < -0.1;
_isFullyClosed := state = eDualMotorPressureBar_AsyncStates.Clamping;
_isFullyOpen := ABS(actualPositionInInches - passthroughSetting) < 0.1;

// Failed to reach sensor timers
_failedToCloseTimer(
	IN := state = eDualMotorPressureBar_AsyncStates.ClosingToFaceplate AND NOT _isFullyClosed,
	PT := _jawCloseMotionFaultTimeOffset,
	Q => failedToClose.faultTrigger);
	
_failedToOpenTimer(
	IN := state = eDualMotorPressureBar_AsyncStates.Opening AND NOT _isFullyOpen,
	PT := _jawOpenMotionFaultTimeOffset,
	Q => failedToOpen.faultTrigger);
  
// Trigger motor faults from drive			
frontMotorFault.faultTrigger := frontMotor.error;
frontMotorCommFault.faultTrigger := NOT frontMotor.commStatus;
pressureBarObstructed.faultTrigger := NOT obstructionSensor AND NOT (actualPositionInInches < 0.01 OR _isFullyOpen);

//	 
_faultONS(CLK := pressureBarObstructed.active OR failedToClose.active OR frontMotorFault.active OR failedToOpen.active OR failedToHome.active);

_startClampingONS(CLK := (actualPositionInInches < _startClampingPosition) AND state = eDualMotorPressureBar_AsyncStates.ClosingToFaceplate);

IF _faultONS.OSR THEN
	state := eDualMotorPressureBar_AsyncStates.Faulting;
END_IF

_ready := state = eDualMotorPressureBar_AsyncStates.Idle AND _isFullyOpen;
// 
IF stopJawTestMode THEN
	jawTestModeActive := FALSE;
END_IF

CASE state OF
	
	eDualMotorPressureBar_AsyncStates.Idle:
	
		//	  
		_ready := _isHomed AND NOT _faultONS.CLK AND InPosition;
	
		 //
		 _timeoutTimer.IN := FALSE;
		_jawTestDelayTimer.IN := FALSE;
		MC_ResetfrontMotor.execute := FALSE;
	
		//	
		IF beginJawTestMode THEN
			jawTestModeActive := TRUE;
			currentTestCycles := 0;
			state := eDualMotorPressureBar_AsyncStates.CloseToFaceplate;
		END_IF
		
		//
		IF _homeNow THEN
			_homeNow := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Home;
		ELSIF _movePassthroughNow THEN
			_movePassthroughNow := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Open;
		ELSIF _openNow OR openJawPB OR _makeReady THEN
			openJawPB := FALSE;
			_openNow := FALSE;
			_makeReady := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Open;
		ELSIF (_closeNow AND _moveInDelay.Q) OR closeJawPB THEN
			closeJawPB := FALSE;
			_closeNow := FALSE;
			state := eDualMotorPressureBar_AsyncStates.CloseToFaceplate;
		END_IF
	
	eDualMotorPressureBar_AsyncStates.Home:
	 	//
		AbsoluteMove(
			motionProfile := openProfile,
			nextState := eDualMotorPressureBar_AsyncStates.Homing
		);
					
	eDualMotorPressureBar_AsyncStates.Homing:
		// Once Homed, Open
		IF MC_MoveFrontMotorABS.done THEN
			_isHomed := TRUE;
			_timeoutTimer.IN := FALSE;
			MC_MoveFrontMotorABS.execute := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Open;
		ELSIF MC_MoveFrontMotorABS.Error OR _timeoutTimer.Q THEN
			failedToHome.Trigger();
			state := eDualMotorPressureBar_AsyncStates.Faulting;
		END_IF	
	
	eDualMotorPressureBar_AsyncStates.Open:	
		// Move jaw out to passthrough
		AbsoluteMove(
			motionProfile := openProfile,
			nextState := eDualMotorPressureBar_AsyncStates.Opening
		);
		
	eDualMotorPressureBar_AsyncStates.Opening:
		// wait for jaw to report open
		IF MC_MoveFrontMotorABS.Done THEN
			
			//
			_timeoutTimer.IN := FALSE;
			MC_MoveFrontMotorABS.execute := FALSE;
			IF jawTestModeActive THEN
				_jawTestDelayTimer.IN := TRUE;
				IF _jawTestDelayTimer.Q THEN
					_jawTestDelayTimer.IN := FALSE;
					state := eDualMotorPressureBar_AsyncStates.CloseToFaceplate;
					currentTestCycles := currentTestCycles + 1;
				END_IF
			ELSE
				state := eDualMotorPressureBar_AsyncStates.Idle;
			END_IF
		ELSIF MC_MoveFrontMotorABS.Error OR _timeoutTimer.Q THEN
			failedToOpen.Trigger();
			state := eDualMotorPressureBar_AsyncStates.Faulting;
		END_IF

	eDualMotorPressureBar_AsyncStates.CloseToFaceplate:	
		// Start Moving jaw to closed position
		AbsoluteMove(
			motionProfile := closeProfile,
			nextState := eDualMotorPressureBar_AsyncStates.ClosingToFaceplate
		);
		
		
		
	eDualMotorPressureBar_AsyncStates.ClosingToFaceplate:
		// Wait for jaw closed indication
		IF _startClampingONS.OSR THEN
			clampingMechanism.StartClamping();
		END_IF
		
		IF MC_MoveFrontMotorABS.Done THEN
			//
			MC_MoveFrontMotorABS.execute := FALSE;
			_timeoutTimer.IN := FALSE;
			IF jawTestModeActive THEN
				_jawTestDelayTimer.IN := TRUE;
				IF _jawTestDelayTimer.Q THEN
					_jawTestDelayTimer.IN := FALSE;
					state := eDualMotorPressureBar_AsyncStates.Open;
				END_IF
			ELSE
				state := eDualMotorPressureBar_AsyncStates.ClosedToFaceplate;
			END_IF
			
		ELSIF MC_MoveFrontMotorABS.Error OR _timeoutTimer.Q THEN
			failedToClose.Trigger();
			state := eDualMotorPressureBar_AsyncStates.Faulting;
		END_IF
		
	eDualMotorPressureBar_AsyncStates.ClosedToFaceplate:
		// Push in and wait for clamping
		AbsoluteMovePush(
			motionProfile := pushProfile,
			nextState := eDualMotorPressureBar_AsyncStates.Clamp
		);
	
	eDualMotorPressureBar_AsyncStates.Clamp:
		// Wait for clamp signal
		
		IF clampingMechanism.Clamping AND MC_MoveFrontMotorPush.Done THEN
			MC_MoveFrontMotorPush.execute := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Clamping;
		END_IF
		
	eDualMotorPressureBar_AsyncStates.Clamping:
		// Wait for clamp complete
		IF _openNow THEN
			clampingMechanism.StopClamping();
			_openNow := FALSE;
		END_IF
		IF clampingMechanism.Cleared THEN
			state := eDualMotorPressureBar_AsyncStates.Open;
		END_IF
	
	eDualMotorPressureBar_AsyncStates.Clamped:
		
	eDualMotorPressureBar_AsyncStates.Faulting:
		// Free up motors on a fault
		_timeoutTimer.IN := FALSE;
		MC_HomeFrontMotor.execute := FALSE;
		MC_MoveFrontMotorABS.execute := FALSE;
		MC_MoveFrontMotorPush.execute := FALSE;
		MC_ResetFrontMotor.execute := FALSE;
 		MC_HaltFrontMotor.execute := TRUE;
		state := eDualMotorPressureBar_AsyncStates.Faulted;
		
	eDualMotorPressureBar_AsyncStates.Faulted:
		//
		IF MC_HaltFrontMotor.Done OR
		   MC_HaltFrontMotor.Error  THEN
			MC_HaltFrontMotor.execute := FALSE;
		END_IF
		
	eDualMotorPressureBar_AsyncStates.Reset:
		//
		_homeNow := FALSE;
		_openNow := FALSE;
		_closeNow := FALSE;
		_timeoutTimer.IN := FALSE;
		jawTestModeActive := FALSE;
		MC_HomeFrontMotor.execute := FALSE;
		MC_MoveFrontMotorABS.execute := FALSE;
		MC_MoveFrontMotorPush.execute := FALSE;
		MC_ResetFrontMotor.execute := TRUE;
		MC_HaltFrontMotor.execute := FALSE;
		state := eDualMotorPressureBar_AsyncStates.Resetting;

	eDualMotorPressureBar_AsyncStates.Resetting:
		//
		IF  _resetTimer.Q THEN
			MC_ResetFrontMotor.Execute := FALSE;	
			state := eDualMotorPressureBar_AsyncStates.ResetDone;
		END_IF
	
	eDualMotorPressureBar_AsyncStates.ResetDone:
		IF frontMotor.operational THEN
			state := eDualMotorPressureBar_AsyncStates.Idle;
		END_IF
END_CASE