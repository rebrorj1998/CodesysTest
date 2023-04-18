(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AZD_AxisTest
VAR_INPUT
	enableClamping : BOOL;
	enableJawMotion : BOOL;
	enableFilmFeedMotion : BOOL;
	startTesting : BOOL;
	stopTesting : BOOL;
	moveInProfile : sctMotionProfile;
	moveOutProfile: sctMotionProfile;
	pushProfile : sctMotionProfile;
	reverseBagFeedProfile : sctMotionProfile;
	forwardBagFeedProfile : sctMotionProfile;
END_VAR

VAR_OUTPUT
	clampError : BOOL;
	jawMotionError : BOOL;
	jawMotionDriveErrorString : STRING;
	jawActualPosition : REAL;
	filmMotionError : BOOL;
	filmMotionDriveErrorString : STRING;
	filmActualPosition : REAL;
	testActive : BOOL;
END_VAR
VAR
	_jogForward : BOOL;
	_jogReverse : BOOL;
	_axis1 : FB_AZDKAxis;
	_axis2 : FB_AZDKAxis;
	_enableJaw : BOOL;
	_PBPowerUP : MC_Power;
	_filmFeedPowerUp : MC_Power;
	_axis1ABS_in : MC_MoveAbsolute;
	_axis1ABS_out : MC_MoveAbsolute;
	_axis1ABSPush : MC_MoveAbsolutePush;
	_axis1ABSPushZero : MC_MoveAbsolutePush;
	_axis1Reset : MC_Reset;
	_axis1Home : MC_Home;
	_axis1Halt : MC_Halt;
	_axis2Reset : MC_Reset;
	_axis2ABS : MC_MoveAbsolute;
	_axis1ABSPos : REAL;
	_ethercatState : WORD;
	_testReset : BOOL;
	_reset : BOOL;
	_jawState : INT;
	_activeKeepJawCycling : BOOL;
	_activeKeepFilmCycling : BOOL;
	_closedPosition : REAL;
	_clampedPosition : REAL := -1;
	_openPosition : REAL := 5.5;
	_closeHoldTimer : Standard.TON := (PT := T#0S);
	_openHoldTimer : Standard.TON := (PT := T#100MS);
	_pushWaitTimer : TON := (PT := T#0MS);
	_haltWaitTimer : TON := (PT := T#50MS);
	_haltClearTimer : TON := (PT := T#500ms);
	_resetState : INT;
	_resettingTimer : Standard.TON := (PT := T#100MS);
	_jawClampTest : FB_JawClampTest();
	_home : BOOL;
	_enablePush : BOOL;
	_enableHalt : BOOL;
	_activeJawMotionProfile : sctMotionProfile;
	_activeFilmMotionProfile : sctMotionProfile;
	_enableFilmFeed : BOOL;
	_filmFeedState : INT;
	_resetONS : FB_ONS;
	clampONS : BOOL;
END_VAR

VAR_IN_OUT
	jawMotionCount : DINT;
	jawClampCount : DINT;
	filmFeedMotionCount : DINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_jawClampTest(
	xExecute:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	driveAlarm:= NOT iPbarClampMotorAlarm, 
	clampMotionInSeconds:= HMIData.jawClampTime, 
	reverseMotionInSeconds:= HMIData.jawClampReverseTime, 
	intervalInSeconds:= HMIData.jawClampInterval, 
	oStartMotor=> oPbarClampMotorStart, 
	oForwardMotor=> oPbarClampMotorReverse, 
	cycleTestActive=> HMIData.jawClampCycleTestActive,
	jawClampCycleTestCounter := jawClampCount
);
_axis1(
	axisData := AxisData.jaw,
	commStatus := TRUE,
	iActualPosition := iFrontJawAxisPositionActualValue,
	iActualVelocity := iFrontJawAxisVelocityActualValue,
	iErrorCode := iFrontJawAxisErrorcode,
	iModeOfOperation := iFrontJawAxisModesOfOperationDisplay,
	iStatusword := iFrontJawAxisStatusword,
	oControlword => oFrontJawAxisControlword,
	oModeOfOperation => oFrontJawAxisModesOfOperation,
	oTargetPosition => oFrontJawAxisTargetPosition,
	oProfileAcceleration => oFrontJawAxisProfileAcceleration,
	oProfileDeceleration => oFrontJawAxisProfileDeceleration,
	oProfileVelocity => oFrontJawAxisProfileVelocity,
	oProfilePushCurrent => oFrontJawAxisPushCurrent,
	oProfileOperationalCurrent => oFrontJawAxisBaseCurrent,
	defaultCurrent := 100.0
);

_axis2(
	axisData := AxisData.FilmFeed,
	commStatus := TRUE,
	iActualPosition := iFilmFeedAxisPositionActualValue,
	iActualVelocity := iFilmFeedAxisVelocityActualValue,
	iErrorCode := iFilmFeedAxisErrorcode,
	iModeOfOperation := iFilmFeedAxisModesOfOperationDisplay,
	iStatusword := iFilmFeedAxisStatusword,
	oControlword => oFilmFeedAxisControlword,
	oModeOfOperation => oFilmFeedAxisModesOfOperation,
	oTargetPosition => oFilmFeedAxisTargetPosition,
	oProfileAcceleration => oFilmFeedAxisProfileAcceleration,
	oProfileDeceleration => oFilmFeedAxisProfileDeceleration,
	oProfileVelocity => oFilmFeedAxisProfileVelocity,
	oProfilePushCurrent => oFilmFeedAxisPushCurrent,
	oProfileOperationalCurrent => oFilmFeedAxisBaseCurrent,
	defaultCurrent := 100.0
);

jawMotionDriveErrorString := TO_STRING(_axis1.alarmCode);
jawActualPosition := _axis1.actualPositonInInches;
jawMotionError := _axis1._statusword.fault;

filmMotionDriveErrorString := TO_STRING(_axis2.alarmCode);
filmActualPosition := _axis2.actualPositonInInches;
filmMotionError := _axis2._statusword.fault;

clampError := NOT iPbarClampMotorAlarm;
testActive := _activeKeepJawCycling;
//
_PBPowerUP(
	enable := F_EtherCatSlaveCommsRunning(state := AZD4A_KED.wState) AND _enableJaw, 
	axis := _axis1
);

_filmFeedPowerUp(
	enable := F_EtherCatSlaveCommsRunning(state := AZD4A_KED.wState) AND _enableFilmFeed, 
	axis := _axis2
);

_axis1Reset(axis := _axis1);
_axis1ABS_in(axis := _axis1);
_axis1ABS_out(axis := _axis1);
_axis1ABSPush(axis := _axis1);
_axis1ABSPushZero(axis := _axis1);
_axis1Home(axis := _axis1);
_axis1Halt(axis := _axis1);

_axis2Reset(axis := _axis2);
_axis2ABS(axis := _axis2);

_axis1ABS_in.acceleration := moveInProfile.acceleration;
_axis1ABS_in.deceleration := moveInProfile.deceleration;
_axis1ABS_in.velocity := moveInProfile.velocity;
_axis1ABS_in.position := moveInProfile.position;
_axis1ABS_in.currentLimit := moveInProfile.current;
//_axis1ABS.execute := _axis1ABSExecute;

_axis1ABSPush.acceleration := pushProfile.acceleration;
_axis1ABSPush.deceleration := pushProfile.deceleration;
_axis1ABSPush.velocity := pushProfile.velocity;
_axis1ABSPush.position := pushProfile.position;
_axis1ABSPush.currentLimit := pushProfile.current;

_axis1ABSPushZero.acceleration := moveInProfile.acceleration;
_axis1ABSPushZero.deceleration := moveInProfile.deceleration;
_axis1ABSPushZero.velocity := 0.7;
_axis1ABSPushZero.position := moveInProfile.position;
_axis1ABSPushZero.currentLimit := 25;

_axis1ABS_out.acceleration := moveOutProfile.acceleration;
_axis1ABS_out.deceleration := moveOutProfile.deceleration;
_axis1ABS_out.velocity := moveOutProfile.velocity;
_axis1ABS_out.position := moveOutProfile.position;
_axis1ABS_out.currentLimit := moveOutProfile.current;

_axis2ABS.acceleration := _activeFilmMotionProfile.acceleration;
_axis2ABS.deceleration := _activeFilmMotionProfile.deceleration;
_axis2ABS.velocity := _activeFilmMotionProfile.velocity;
_axis2ABS.position := _activeFilmMotionProfile.position;
_axis2ABS.currentLimit := _activeFilmMotionProfile.current;
//_axis1ABSPush.execute := ;

_closeHoldTimer(IN := (_jawState = 24) AND NOT enableClamping);
_openHoldTimer(IN := _jawState = 11 AND _axis1ABS_out.Done);
_pushWaitTimer(IN := _jawState = 21 AND _axis1ABS_in.Done);
_haltWaitTimer(IN := _jawState = 25 AND _enableHalt);
_haltClearTimer(IN := _jawState = 26 AND _enableHalt);
IF stopTesting THEN
	_jawState := 0;
	_filmFeedState := 0;
	_activeKeepJawCycling := FALSE;
	_activeKeepFilmCycling := FALSE;
END_IF

IF enableClamping AND _jawState = 21 AND _axis1.actualPositonInInches < 5.5 AND NOT clampONS THEN
	_jawClampTest.Start();
	clampONS := TRUE;
END_IF

CASE _jawState OF
	0: // Idle
		_axis1ABSPush.execute := FALSE;
		_axis1ABS_in.execute := FALSE;
		_axis1ABS_out.execute := FALSE;
		IF (startTesting AND enableJawMotion) OR _activeKeepJawCycling THEN
			_jawState := 10;
			_activeKeepJawCycling := TRUE;
		ELSIF (startTesting AND (enableClamping AND NOT enableJawMotion)) THEN
			_jawState := 30;
		END_IF
		
	10: // Open Up
		_activeJawMotionProfile := moveOutProfile;
		_axis1ABS_out.execute := TRUE;
		_jawState := 11;
	
	11: // Wait for open
		
		IF _axis1ABS_out.Done AND _openHoldTimer.Q THEN
			_axis1ABS_out.execute := FALSE; 
			_jawState := 20;
		END_IF
		
	20: // Close to 0

 		_activeJawMotionProfile := moveInProfile;
		_axis1ABS_in.execute := TRUE;
		_jawState := 21;
		
	21: // Wait for close
		
		IF _axis1ABS_in.Done THEN
			//_axis1ABS.execute := FALSE;
			_axis1ABS_in.execute := FALSE;
			//IF enableClamping AND NOT clampONS THEN
			//	_jawClampTest.Start();
			//	clampONS := TRUE;
			//END_IF
			IF _enablePush AND _pushWaitTimer.Q THEN
				_jawState := 22;
				clampONS := FALSE;
			ELSIF NOT _enablePush THEN
				_jawState := 24;
			END_IF
			
			
		END_IF
		
	22: // Push in
		_activeJawMotionProfile := pushProfile;
		_axis1ABSPush.execute := TRUE;
		_jawState := 23;
		//Hold
		
		
	23: //Wait for pushed in
		
		
		IF _axis1ABSPush.Done  THEN
			_axis1ABSPush.execute := FALSE;
			_jawState := 24;
		END_IF
				
	24: // hold
		//IF _jawClampTest.Done OR _closeHoldTimer.Q THEN
		IF _jawClampTest.Done OR _closeHoldTimer.Q THEN
			_haltWaitTimer.IN := FALSE;
			jawMotionCount := jawMotionCount + 1;
			IF enableClamping THEN
				jawClampCount := jawClampCount + 1;
			END_IF
			
			IF _enableHalt THEN
				_axis1ABSPushZero.execute := TRUE;
				//_axis1Halt.execute := TRUE;
				//_axis1.halt := TRUE;				
				_jawState := 25;
			ELSE
				_jawState := 0;
			END_IF		
		END_IF
	
	25: //wait for halt delay
		//_axis1Halt.execute := FALSE;
		IF _enableHalt AND _haltWaitTimer.Q AND _axis1ABSPushZero.Done THEN
			_axis1ABSPushZero.execute := FALSE;
			//_axis1.halt := FALSE;	
			_jawState := 26;
		END_IF 	
		
	26: // Wait to move until halt is off for a bit
		IF _haltClearTimer.Q THEN
			_jawState := 0;
		END_IF
		
	30: // Clamp Cycle Only
		_jawClampTest.Start();
		_jawState := 31;
	
	31: // 
		IF _jawClampTest.Done THEN
			_jawState := 0;
			jawClampCount := jawClampCount + 1;
		END_IF
		
		
END_CASE


// Film Feed state machine
CASE _filmFeedState OF
	0: // Idle
		_axis2ABS.execute := FALSE;
		IF (startTesting AND enableFilmFeedMotion) OR _activeKeepFilmCycling THEN
			_filmFeedState := 10;
			_activeKeepFilmCycling := TRUE;
		END_IF
		
	10: // Back Up
		_activeFilmMotionProfile := reverseBagFeedProfile;
		_axis2ABS.execute := TRUE;
		_filmFeedState := 11;
		
	11: // Wait for reverse
		IF _axis2ABS.Done THEN
			_axis2ABS.execute := FALSE; 
			_filmFeedState := 20;
		END_IF
		
	20: // Feed forward
		_activeFilmMotionProfile := forwardBagFeedProfile;
		_axis2ABS.execute := TRUE;
		_filmFeedState := 21;
		
	21: // Wait for reverse
		IF _axis2ABS.Done THEN
			_axis2ABS.execute := FALSE; 
			filmFeedMotionCount := filmFeedMotionCount + 1;
			_filmFeedState := 0;
		END_IF
		
END_CASE



// Reset everything

_resetONS(CLK := HMIData.jawResetDrives);
_resettingTimer(IN := _resetState = 10);
CASE _resetState OF
	0: // Clear Flags
		IF _resetONS.OSR THEN
			//_reset := FALSE;
			_axis1ABSPush.execute := FALSE;
			_axis1ABS_in.execute := FALSE;
			_axis1ABS_out.execute := FALSE;
			_axis1ABSPushZero.execute := FALSE;
			_axis1Reset.execute := FALSE;
			_axis2ABS.execute := FALSE;
			_axis2Reset.execute := FALSE;
			_enableJaw := FALSE;
			_enableFilmFeed := FALSE;
			_activeKeepJawCycling := FALSE;
			_activeKeepFilmCycling := FALSE;
			_resetState := 10;
		END_IF
		
	10: // reset axis'
		_jawState := 0;
		_axis1Reset.execute := TRUE;
		_axis2Reset.execute := TRUE;
		IF _resettingTimer.Q THEN
			_axis1Reset.execute := FALSE;
			_axis2Reset.execute := FALSE;
			_enableJaw := TRUE;
			_enableFilmFeed := TRUE;
			_resetState := 11;
		END_IF
		
	11: // wait for power up
		IF _axis1.operational AND _axis2.operational THEN
			_resetState := 20;
		END_IF
		
	20: // Move the jaw out
		_activeJawMotionProfile := moveOutProfile;
		_axis1ABS_out.execute := TRUE;
		_resetState := 21;
		
	21:
		IF _axis1ABS_out.Done THEN
			_axis1ABS_out.execute := FALSE;
			_resetState := 0;
		END_IF
END_CASE

