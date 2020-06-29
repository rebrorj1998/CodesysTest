(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedIBD EXTENDS BaseComponentFB
VAR_INPUT
	pbarOutSetting : REAL := 12.0;
	pbarInSetting : REAL;
	disableFaults : BOOL;
	extendCommand : BOOL;
	retractCommand : BOOL;
END_VAR
VAR_OUTPUT
	
	failToClose : FB_Fault(name := 'IBD Fail to Close');
	failToOpen : FB_Fault(name := 'IBD Fail to Open');
	state : MotorizedPbarStates;
	actualPosition : REAL;
	IBDOpen : BOOL;
	homeRequired : BOOL;
	clamped : BOOL;
END_VAR
VAR
	_homeNow : BOOL;
	_openIBD : BOOL;
	_closeIBD : BOOL;
	accel : INT := 300;
	decel : INT := 300;
	velo : INT := 2500;
	testCurrent : DINT := 200;
	testZeroCurrent : BOOL;
	testSomeCurrent : BOOL;
	startTest : BOOL;
	testActive : BOOL;
	movePassthroughNow : BOOL;
	delayTimer : Standard.TON := (PT:= T#500MS);
END_VAR
VAR_IN_OUT
	IBDMotor : FB_AppliedMotionStepServoEIPPassthrough;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

actualPosition := IBDMotor.absolutePositonInches;
IBDOpen := IBDMotor.InPosition;
//IBDOpen := TO_DINT(IBDMotor.absolutePositonInches) = TO_DINT(pbarOutSetting);
delayTimer();

clamped := state = MotorizedPbarStates.Clamping;


IF NOT IBDMotor.HomeRequired THEN
	IF extendCommand THEN
		extendCommand := FALSE;
		IBDMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
	ELSIF retractCommand THEN
		retractCommand := FALSE;
		IBDMotor.MoveToPositionTorque(pbarInSetting,accel,decel,velo,testCurrent);
	END_IF
END_IF


IF testZeroCurrent THEN
	IBDMotor.SetTorque(0);
	testZeroCurrent := FALSE;
END_IF

IF testSomeCurrent THEN
	IBDMotor.SetTorque(testCurrent);
	testSomeCurrent := FALSE;
END_IF


IF _reset THEN
	IBDMotor.Reset();
	//IBDMotor.Reset();
	Globals.jawMovingIn := FALSE;
	_reset := FALSE;
	startTest := FALSE;
	testActive := FALSE;
	delayTimer.IN := FALSE;
	state := MotorizedPbarStates.Idle; 
END_IF

IF 	(	IBDMotor.Faulted AND NOT disableFaults)
	AND state <> MotorizedPbarStates.Faulted
THEN
	state := MotorizedPbarStates.Faulting; 
END_IF

IF IBDMotor.homeRequired THEN
	homeRequired := TRUE;
END_IF

_ready := state = MotorizedPbarStates.Idle AND NOT homeRequired AND IBDOpen;

CASE state OF
	MotorizedPbarStates.Idle :					//
										IF startTest THEN
											startTest := FALSE;
											testActive := TRUE;
											IF IBDMotor.homeRequired THEN
												IBDMotor.HomeNow();
												state := MotorizedPbarStates.Homing;
											ELSE
												state := MotorizedPbarStates.Initialize;
											END_IF
												
										END_IF
											
										IF _homeNow THEN
											_homeNow := FALSE;
											IBDMotor.HomeNow();
											state := MotorizedPbarStates.Homing;
										END_IF
										
										IF _openIBD THEN
											_openIBD := FALSE;
											state := MotorizedPbarStates.MoveJawOut;
										END_IF
										
										IF _closeIBD THEN
											_closeIBD := FALSE;
											state := MotorizedPbarStates.MoveJawIn;
										END_IF
	
	MotorizedPbarStates.Homing :				//
										
										IF NOT (IBDMotor.homeRequired) THEN
												homeRequired := FALSE;
												state := MotorizedPbarStates.Initialize;
										END_IF
	
	
	MotorizedPbarStates.Initialize :			//
										
										IF IBDOpen THEN
											state := MotorizedPbarStates.Initialized;
										ELSE
											IBDMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
											//IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
											state := MotorizedPbarStates.Initializing;
										END_IF
	
	
	MotorizedPbarStates.Initializing :			//
										IF IBDOpen THEN
											state := MotorizedPbarStates.Initialized;
										END_IF
	
	
	MotorizedPbarStates.Initialized :			//
										state := MotorizedPbarStates.Idle;
	
	
	MotorizedPbarStates.MoveJawOut :			//
										
										//IBDMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
										IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
										state := MotorizedPbarStates.MovingJawOut;
										//IBDMotor.SetPositionLimit(150);
	
	MotorizedPbarStates.MovingJawOut :			//
										IF IBDOpen THEN
											state := MotorizedPbarStates.Idle;
										END_IF
	
	
	MotorizedPbarStates.MovedJawOut :			//
										
	
	
	MotorizedPbarStates.MoveJawIn :				//
									
										IBDMotor.MoveToPositionTorque(pbarInSetting,accel,decel,velo,testCurrent);
										//IBDMotor.MoveToPosition(0,accel,decel,velo+(TO_INT(TO_REAL(velo)*0.25)));
										state := MotorizedPbarStates.MovingJawIn;
	
	
	MotorizedPbarStates.MovingJawIn : 			//
										IF IBDMotor.alarms.currentFoldback OR IBDMotor.InPosition THEN
											state := MotorizedPbarStates.Clamping;
										END_IF
	
	
	MotorizedPbarStates.MovedJawIn :			//
										state := MotorizedPbarStates.StartClamping;
	
	
	MotorizedPbarStates.StartClamping :			//
										
	
	MotorizedPbarStates.StartedClamping :		//
										
	
	
	MotorizedPbarStates.Clamping :				//
										IF _openIBD THEN
											state := MotorizedPbarStates.MoveJawOut;
										END_IF
	
	
	
	MotorizedPbarStates.ReleaseClamp :			//  
										
	
	MotorizedPbarStates.ReleasingClamp :		//
										
	
	MotorizedPbarStates.Faulting :			// 
										Globals.jawMovingIn := FALSE;
										_reset := FALSE;
										_openIBD := FALSE;
										_closeIBD := FALSE;
										_homeNow := FALSE;
										startTest := FALSE;
										testActive := FALSE;
										delayTimer.IN := FALSE;
										IBDMotor.MoveDistanceTorque(velocity:=100, acceleration := 1, deceleration := 1, distance := 0, current := 0);
										//IBDMotor.Disable();
										state := MotorizedPbarStates.Faulted;
	
	MotorizedPbarStates.Faulted :				//
	
END_CASE
