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
	setZero : BOOL := FALSE;
	adjClampedPos : REAL := 0.3;
	clampBypass: BOOL:=FALSE;
	motionInhibit: BOOL :=FALSE;
	cleanup_ons : FB_ONS;
END_VAR
VAR_OUTPUT
	pressureBarObstructed : FB_Fault(name := CONCAT(_prefix, 'Obstructed'));
	frontMotorFault : FB_Fault(name := CONCAT(_prefix, 'Front Motor Fault'));
	frontMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Front Motor Comm Fault'));
	failedToClose : FB_Fault(name := CONCAT(_prefix, 'Failed to Close'));
	failedToOpen : FB_Fault(name := CONCAT(_prefix, 'Failed to Open'));
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home '));
	pressurebarTimeOut : FB_Fault(name := CONCAT(_prefix, 'Time Out'));
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
	feedOpeningInches: REAL:= 2.0;
	_isReadyForFeed: BOOL:= FALSE;
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
	_moveOutDelay : Standard.TON := (PT := T#100MS);//T#100MS);
	_moveOutTimeOut : Standard.TON := (PT := T#1250MS);
	_jawOpenPositionDelta : REAL;
	_moveOutStuckCount : INT := 0;
	_haltWaitTimer : TON := (PT := T#50MS);
	_lastState : eDualMotorPressureBar_AsyncStates;
	setZeroONS : FB_ONS;
	zeroNow : BOOL := false;
	//
	Test:BOOL;
	clampingReleaseDebounce: TON:= (PT := T#100MS);
	
		//variables for the state timer
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
	state_index : INT:=0;
	zeroNowTON: Ton;
	_activeFault: BOOL;
	_homeloc: BOOL;
	clamp_pos: REAL;
	posONS: FB_ONS;
	stepTON1:TON;
	stepTON2:TON;
	stepChange: BOOL;
	stepChangeONS: FB_ONS;
	priorstate: eDualMotorPressureBar_AsyncStates;
	clampingState: BOOL;
	peak_velo: REAL;
	min_velo: REAL;
	clampPushed: BOOL;
	_busy: BOOL;

	init_vars: BOOL;
	_maintenanceMove: BOOL;
END_VAR
VAR PERSISTENT
	factoryHomeJaw: BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_DualMotorPressureBar_Async()
//	Description: Dual motor passthough, using a low torque positionable motor for most movements and a high torque brushless motor for clamping force to seal and 
//				 reverse bag			 
//	Created by: Ben Hess
//	Created Date: 4/11/2023

SUPER^();
stepTON1(PT:=T#10000MS,IN:=stepChange AND NOT _reset AND NOT (state = eDualMotorPressureBar_AsyncStates.Idle OR state = eDualMotorPressureBar_AsyncStates.Faulted ));
stepTON2(PT:=stepTON1.PT,in:=NOT stepChange  AND NOT _reset AND NOT (state = eDualMotorPressureBar_AsyncStates.Idle OR state = eDualMotorPressureBar_AsyncStates.Faulted ));
setZeroONS(CLK:=setZero);
zeroNowTON(PT:=T#10S,IN:=zeroNow);
stepChangeONS(clk:= NOT (priorstate = state));
IF stepChangeONS.OSR THEN
	stepChange:=NOT stepChange;
END_IF
_isHomed := _isFullyOpen;
IF setZeroONS.OSR THEN
	zeroNow := TRUE;
END_IF
test:= IsReadyForFeed;
_busy:= frontMotor.axisState <> eAxisState.Standstill;
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

// Jaw move out delay
_moveOutDelay (IN :=  state = eDualMotorPressureBar_AsyncStates.Open);
_moveOutTimeOut(IN := state = eDualMotorPressureBar_AsyncStates.Opening AND _jawOpenPositionDelta < 0.1);
_haltWaitTimer(IN :=  state = eDualMotorPressureBar_AsyncStates.HaltDelay);
	 
// Passthrough position is based on reported motor position

actualPositionInInches := frontMotor.actualPositonInInches;
	 
//_isFullyClosed := actualPositionInInches < -0.1;
//_isFullyClosed := state = eDualMotorPressureBar_AsyncStates.Clamping;
_isReadyForFeed :=actualPositionInInches > feedOpeningInches;
_isFullyOpen := ABS(actualPositionInInches - passthroughSetting) < 0.1;

// Failed to reach sensor timers
_failedToCloseTimer(
	IN := state = eDualMotorPressureBar_AsyncStates.ClosingToFaceplate AND NOT _isFullyClosed AND NOT closeJawPB,
	PT := _jawCloseMotionFaultTimeOffset,
	Q => failedToClose.faultTrigger);
	
_failedToOpenTimer(
	IN := state = eDualMotorPressureBar_AsyncStates.Opening AND NOT _isFullyOpen,
	PT := _jawOpenMotionFaultTimeOffset,
	Q => failedToOpen.faultTrigger);
  
// Trigger motor faults from drive			
frontMotorFault.faultTrigger := frontMotor.error;
frontMotorCommFault.faultTrigger := NOT frontMotor.commStatus;
pressureBarObstructed.faultTrigger := NOT zeroNow AND NOT obstructionSensor AND NOT (actualPositionInInches < 0.06 OR _isFullyOpen);
pressurebarTimeOut.faultTrigger:= stepTON1.Q OR stepTON2.Q;
_activeFault := pressurebarTimeOut.Active OR pressureBarObstructed.Active OR failedToClose.Active OR frontMotorFault.Active OR failedToOpen.Active OR failedToHome.Active;
//	 
_faultONS(CLK := _activeFault);

_startClampingONS(CLK := (actualPositionInInches < _startClampingPosition) AND state = eDualMotorPressureBar_AsyncStates.ClosingToFaceplate AND clampingMechanism.Ready);

IF _faultONS.OSR THEN
	state := eDualMotorPressureBar_AsyncStates.Faulting;
END_IF

//code to add timer to track duration in states
stateTimer(PT:=T#10000S);
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
_ready := state = eDualMotorPressureBar_AsyncStates.Idle AND _isFullyOpen;
// 
IF stopJawTestMode THEN
	jawTestModeActive := FALSE;
END_IF
IF motionInhibit THEN
	state:= eDualMotorPressureBar_AsyncStates.Idle;
END_IF
cleanup_ons(CLK:=state = eDualMotorPressureBar_AsyncStates.Idle);


CASE state OF
	
	eDualMotorPressureBar_AsyncStates.Idle:
		state_index:=0;
		//	  
		IF cleanup_ons.OSR THEN
			SterilizeVariables();
		END_IF 
		_ready := _isHomed AND NOT _faultONS.CLK AND InPosition;
		_isFullyClosed := FALSE;
		 //
		 _timeoutTimer.IN := FALSE;
		_jawTestDelayTimer.IN := FALSE;
		MC_ResetfrontMotor.execute := FALSE;
		
		//	
		IF NOT motionInhibit THEN
			IF beginJawTestMode THEN
				jawTestModeActive := TRUE;
				currentTestCycles := 0;
				state := eDualMotorPressureBar_AsyncStates.CloseToFaceplate;
			END_IF
		
		//

			IF _homeNow THEN
				_homeNow := FALSE;
				state := eDualMotorPressureBar_AsyncStates.Home;
			ELSIF 	zeroNow THEN
				state := eDualMotorPressureBar_AsyncStates.Home;
			ELSIF _movePassthroughNow THEN
				_movePassthroughNow := FALSE;
				state := eDualMotorPressureBar_AsyncStates.Open;
			ELSIF _openNow OR openJawPB OR _makeReady THEN
				_openNow := _makeReady :=  openJawPB := FALSE;
				state := eDualMotorPressureBar_AsyncStates.Open;
			ELSIF (_closeNow AND _moveInDelay.Q) OR closeJawPB THEN
				_maintenanceMove := TRUE;
				_closeNow := FALSE;
				state := eDualMotorPressureBar_AsyncStates.CloseToFaceplate;
			END_IF
		END_IF
	
	eDualMotorPressureBar_AsyncStates.Home:
		state_index:=8;	 	
//
		IF clampingMechanism.IsHomed  THEN
			IF NOT zeroNow THEN
			AbsoluteMove(
				motionProfile := openProfile,
				nextState := eDualMotorPressureBar_AsyncStates.Homing
			);
			ELSIF zeroNow THEN
				State := eDualMotorPressureBar_AsyncStates.Homing;
			END_IF
		ELSE
			clampingMechanism.HomeNow();
		END_IF
					
	eDualMotorPressureBar_AsyncStates.Homing:
		state_index:=10;
		// Once Homed, Open
		IF NOT zeroNow THEN
			IF MC_MoveFrontMotorABS.done THEN
				_homeloc := TRUE;
				_timeoutTimer.IN := FALSE;
				MC_MoveFrontMotorABS.execute := FALSE;
				state := eDualMotorPressureBar_AsyncStates.Open;
			ELSIF MC_MoveFrontMotorABS.Error OR _timeoutTimer.Q THEN
				failedToHome.Trigger();
				state := eDualMotorPressureBar_AsyncStates.Faulting;
			END_IF
		ELSIF zeroNow THEN
			MC_HomeFrontMotor.execute:= TRUE;
			IF MC_HomeFrontMotor.homeSuccess THEN
				zeroNow:=FALSE;
				MC_HomeFrontMotor.execute:= FALSE;
				factoryHomeJaw := TRUE;
			ELSIF factoryHomeJaw THEN
				state:=eDualMotorPressureBar_AsyncStates.Home;
			ELSIF zeroNowTON.Q THEN 
				failedToHome.Trigger();
				state := eDualMotorPressureBar_AsyncStates.Faulting;
			END_IF
		END_IF

	
	eDualMotorPressureBar_AsyncStates.Open:	
		state_index:=1;
		// Move jaw out to passthrough
		_isFullyClosed := FALSE;
		clampingMechanism.StopClamping();
		IF  clampingMechanism.Cleared AND NOT _busy THEN
		IF _moveOutDelay.Q THEN
			AbsoluteMove(
				motionProfile := openProfile,
				nextState := eDualMotorPressureBar_AsyncStates.Opening
			);
		END_IF
		END_IF
		
	eDualMotorPressureBar_AsyncStates.Opening:
		_isFullyClosed := FALSE;
		state_index:=2;
		_jawOpenPositionDelta := ABS(HMIData.passthroughSetting - MC_MoveFrontMotorABS.position);
	
		// wait for jaw to report open
		IF MC_MoveFrontMotorABS.Done AND _jawOpenPositionDelta <0.1  THEN
			state := eDualMotorPressureBar_AsyncStates.Opened;
		ELSIF MC_MoveFrontMotorABS.Error OR _timeoutTimer.Q THEN
			failedToOpen.Trigger();
			state := eDualMotorPressureBar_AsyncStates.Faulting;
		// moveOutTimeOut to fix oriental motor getting stuck in out position
		ELSIF _moveOutTimeOut.Q  THEN
			MC_HaltFrontMotor.execute := TRUE;
			_moveOutStuckCount := _moveOutStuckCount + 1;	
			state := eDualMotorPressureBar_AsyncStates.HaltDelay;		
		END_IF

		eDualMotorPressureBar_AsyncStates.Opened:
			_isFullyClosed := FALSE;
			state_index:=11;
			//
			openJawPB :=_openNow := _makeReady :=  FALSE;
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
				_homeloc := TRUE;
				state := eDualMotorPressureBar_AsyncStates.Idle;
			END_IF
			
	eDualMotorPressureBar_AsyncStates.HaltDelay:	
		state_index:=6;
		//Wait for communication interval per datasheet to turn off then close jaw
		IF _haltWaitTimer.Q THEN
			MC_HaltFrontMotor.execute := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Opened;
		END_IF
				
	eDualMotorPressureBar_AsyncStates.CloseToFaceplate:
		_isFullyClosed := FALSE;
		state_index:=7;	
		// Start Moving jaw to closed position
		IF clampingMechanism.Cleared OR (clampingMechanism.Moving AND NOT clampingMechanism.Forward) THEN
			AbsoluteMove(
				motionProfile := closeProfile,
				nextState := eDualMotorPressureBar_AsyncStates.ClosingToFaceplate
			);	
		ELSE
			clampingMechanism.HomeNow();
		END_IF
		
	eDualMotorPressureBar_AsyncStates.ClosingToFaceplate:
		_isFullyClosed := FALSE;
		state_index:=3;
		// Wait for jaw closed indication
		IF _startClampingONS.OSR AND NOT clampBypass AND NOT _maintenanceMove THEN
			clampingMechanism.StartClamping();
		END_IF
		IF  (clampingMechanism.Moving AND clampingMechanism.Forward) OR clampBypass OR _maintenanceMove THEN
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
			END_IF
		ELSIF MC_MoveFrontMotorABS.Error OR _timeoutTimer.Q THEN
			failedToClose.Trigger();
			state := eDualMotorPressureBar_AsyncStates.Faulting;
		END_IF
		
	eDualMotorPressureBar_AsyncStates.ClosedToFaceplate:
		_isFullyClosed := FALSE;
		state_index:=9;
		// Push in and wait for clamping
		IF _maintenanceMove THEN
			MC_MoveFrontMotorPush.execute := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Idle;
		ELSE
			IF NOT clampingMechanism.Cleared OR clampBypass THEN
			AbsoluteMovePush(
				motionProfile := pushProfile,
				nextState := eDualMotorPressureBar_AsyncStates.Clamp
			);
			END_IF
			clampingState := TRUE;
			clamp_pos := 0.0;
			peak_velo := 0;
			min_velo := 10000;
			clampPushed:=FALSE;
		END_IF
	
	eDualMotorPressureBar_AsyncStates.Clamp:
		_isFullyClosed := FALSE;
		state_index:=4;
		// Wait for clamp signal

		IF NOT clampBypass THEN
			IF NOT obstructionSensor AND FrontMotor.actVel<800 AND actualPositionInInches< adjClampedPos AND clampingState THEN
				clampingState := FALSE;
				IF clamp_pos< ABS(actualPositionInInches) THEN
					clamp_pos := actualPositionInInches;
				END_IF
			END_IF
			IF NOT clampingState THEN
				IF ABS(frontMotor.actVel) > peak_velo  THEN
					peak_velo := ABS(frontMotor.actVel);
				END_IF
				IF ABS(frontMotor.actVel) < min_velo AND frontMotor.actVel <>0 THEN
					min_velo := ABS(frontMotor.actVel);
				END_IF
				IF ABS(frontMotor.actVel) > 1000.0 THEN
					clampPushed:=TRUE;
				END_IF
				IF clamp_pos< ABS(actualPositionInInches) THEN
				clamp_pos := actualPositionInInches;
				END_IF
			END_IF
		ELSE
			clampingState:= FALSE;
		END_IF
		IF (NOT clampingState AND clampPushed) OR clampBypass THEN
			
			state := eDualMotorPressureBar_AsyncStates.Clamping;
		END_IF
		
	eDualMotorPressureBar_AsyncStates.Clamping:
		state_index:=5;
		_isFullyClosed:= TRUE;
		// Wait for clamp complete
		IF _openNow THEN
			clampingMechanism.StopClamping();

			//MC_HaltFrontMotor.execute := FALSE;
			_openNow := FALSE;
			
		END_IF
		IF NOT clampingMechanism.Clamping AND ((clampingMechanism.Moving AND NOT clampingMechanism.Forward) OR clampingMechanism.Cleared)  THEN
			MC_MoveFrontMotorPush.execute := FALSE;
			state := eDualMotorPressureBar_AsyncStates.Open;
		END_IF
	
	eDualMotorPressureBar_AsyncStates.Clamped:
		state_index:=12;
		
	eDualMotorPressureBar_AsyncStates.Halting:
		state_index:=18;
		// Free up motors on a Halt
		_timeoutTimer.IN := FALSE;
		MC_HomeFrontMotor.execute := FALSE;
		MC_MoveFrontMotorABS.execute := FALSE;
		MC_MoveFrontMotorPush.execute := FALSE;
		MC_ResetFrontMotor.execute := FALSE;
		//7-17-2023 CT Removed comments on MC_HaltFrontMotor.execute:=TRUE;  No reason could be found for this bypass.
 		MC_HaltFrontMotor.execute := TRUE;
		IF _activeFault THEN
			state := eDualMotorPressureBar_AsyncStates.Faulted;
		ELSE
			state := eDualMotorPressureBar_AsyncStates.Idle;
		END_IF
	eDualMotorPressureBar_AsyncStates.Faulting:
		state_index:=13;
		// Free up motors on a fault
// 		_timeoutTimer.IN := FALSE;
// 		MC_HomeFrontMotor.execute := FALSE;
// 		MC_MoveFrontMotorABS.execute := FALSE;
// 		MC_MoveFrontMotorPush.execute := FALSE;
// 		MC_ResetFrontMotor.execute := FALSE;
		//7-17-2023 CT Removed comments on MC_HaltFrontMotor.execute:=TRUE;  No reason could be found for this bypass.
 		//MC_HaltFrontMotor.execute := TRUE;
		state := eDualMotorPressureBar_AsyncStates.halting;
		
	eDualMotorPressureBar_AsyncStates.Faulted:
		state_index:=14;		
//
		IF MC_HaltFrontMotor.Done OR
		   MC_HaltFrontMotor.Error  THEN
			MC_HaltFrontMotor.execute := FALSE;
		END_IF
		
	eDualMotorPressureBar_AsyncStates.Reset:
		state_index:=15;
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
		zeroNow:= FALSE;
		state := eDualMotorPressureBar_AsyncStates.Resetting;

	eDualMotorPressureBar_AsyncStates.Resetting:
		state_index:=16;
		//
		IF  _resetTimer.Q THEN
			MC_ResetFrontMotor.Execute := FALSE;	
			state := eDualMotorPressureBar_AsyncStates.ResetDone;
		END_IF
	
	eDualMotorPressureBar_AsyncStates.ResetDone:
		state_index:=17;
		IF frontMotor.operational THEN
			state := eDualMotorPressureBar_AsyncStates.Idle;
		END_IF
END_CASE