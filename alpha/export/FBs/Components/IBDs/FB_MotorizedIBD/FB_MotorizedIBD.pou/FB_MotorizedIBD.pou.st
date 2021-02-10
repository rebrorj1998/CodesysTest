(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedIBD EXTENDS FB_BaseComponent
VAR_INPUT
	pbarOutSetting : REAL := 12.0;
	IBDOutCalculated : REAL := 12.0;
	inPositionSetting : REAL;
	IBDOffsetToJaw : REAL := 2.0;
	disableFaults : BOOL;
	extendCommand : BOOL;
	retractCommand : BOOL;
END_VAR
VAR_OUTPUT
	failToOpen : FB_Fault(name := 'IBD Fail to Open');
	state : MotorizedIBDStates;
	actualPosition : REAL;
	IBDOpen : BOOL;
	IBDFullyOpen : BOOL;
	homeRequired : BOOL;
	clamped : BOOL;
END_VAR
VAR
	_homeNow : BOOL;
	_openIBD : BOOL;
	_closeIBD : BOOL;
	_openFull : BOOL;
	accel : INT := 150;
	decel : INT := 100;
	velo : INT := 1250;
	testCurrent : DINT := 500;
	testZeroCurrent : BOOL;
	testSomeCurrent : BOOL;
	startTest : BOOL;
	testActive : BOOL;
	movePassthroughNow : BOOL;
	delayTimer : Standard.TON := (PT:= T#500MS);
	failToOpenTimer : Standard.TON := (PT := T#2s);
	homeRequiredONS : FB_ONS;
	faultingONS : FB_ONS;
	feedbackHandler : FB_CylinderFeedback;
END_VAR
VAR_IN_OUT
	IBDMotor : FB_AppliedMotionStepServoEIPPassthrough;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

actualPosition := IBDMotor.absolutePositonInches;
IBDOpen := TO_DINT(actualPosition * 1000) >= (TO_DINT((pbarOutSetting) * 1000) - 10) AND TO_DINT(actualPosition * 1000) <= (TO_DINT((pbarOutSetting)* 1000) + 10);
IBDFullyOpen := TO_DINT(actualPosition * 1000) >= (TO_DINT(12 * 1000) - 10) AND TO_DINT(actualPosition * 1000) <= (TO_DINT(12 * 1000) + 10);
//IBDOpen := TO_DINT(IBDMotor.absolutePositonInches) = TO_DINT(pbarOutSetting);
delayTimer();

clamped := state = MotorizedIBDStates.Clamping;

failToOpenTimer(IN := state = MotorizedIBDStates.MovingJawOut OR state = MotorizedIBDStates.MovingOutFull);

IF NOT IBDMotor.HomeRequired THEN
	IF extendCommand THEN
		extendCommand := FALSE;
		IBDMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
	ELSIF retractCommand THEN
		retractCommand := FALSE;
		IBDMotor.MoveToPositionTorque(inPositionSetting,accel,decel,velo,testCurrent);
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


IF resetONS.Q THEN
	//IF IBDMotor.Faulted THEN
		IBDMotor.Reset();
	//END_IF
	IBDMotor.ResetEncoderPosition(IBDMotor.driveInputs[5]);
	_reset := FALSE;
	_openIBD := FALSE;
	_closeIBD := FALSE;
	_homeNow := FALSE;
	startTest := FALSE;
	testActive := FALSE;
	delayTimer.IN := FALSE;
	state := MotorizedIBDStates.Idle; 
END_IF
faultingONS(CLK := IBDMotor.Faulted AND NOT disableFaults);

IF (faultingONS.OSR AND disableFaults)
	AND state <> MotorizedIBDStates.Faulted
THEN
	state := MotorizedIBDStates.Faulting; 
END_IF

homeRequiredONS(CLK := IBDMotor.homeRequired);
IF homeRequiredONS.OSR THEN
	homeRequired := TRUE;
END_IF

_ready := state = MotorizedIBDStates.Idle AND NOT homeRequired AND IBDOpen;

CASE state OF
	MotorizedIBDStates.Idle :					//
										IF startTest THEN
											startTest := FALSE;
											testActive := TRUE;
											IF IBDMotor.homeRequired THEN
												IBDMotor.HomeNow();
												state := MotorizedIBDStates.Homing;
											ELSE
												state := MotorizedIBDStates.Initialize;
											END_IF
												
										END_IF
											
										
										IF IBDMotor.status.motorEnabled THEN
											IF _openIBD THEN
												IF NOT IBDOpen THEN
													state := MotorizedIBDStates.MoveJawOut;
												END_IF	
											_openIBD := FALSE;
										END_IF
										
										IF _closeIBD THEN
											_closeIBD := FALSE;
											state := MotorizedIBDStates.MoveJawIn;
										END_IF
										
										IF _openFull THEN
											_openFull := FALSE;
											state := MotorizedIBDStates.MoveOutFull;
										END_IF
										
										IF _homeNow THEN
											_homeNow := FALSE;
											//IF IBDMotor.HomeRequired THEN
												IBDMotor.HomeNow();
											//END_IF
											delayTimer.PT := T#150MS;
											delayTimer.IN := TRUE;
											state := MotorizedIBDStates.Homing;
										END_IF
										END_IF
										
	
	MotorizedIBDStates.Homing :				//
										
										IF NOT (IBDMotor.homeRequired) AND delayTimer.Q THEN
											delayTimer.IN := FALSE;
											homeRequired := FALSE;
											state := MotorizedIBDStates.Initialize;
										END_IF
	
	
	MotorizedIBDStates.Initialize :			//
										
										IF IBDOpen THEN
											state := MotorizedIBDStates.Initialized;
										ELSE
											IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
											//IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
											state := MotorizedIBDStates.Initializing;
										END_IF
	
	
	MotorizedIBDStates.Initializing :			//
										IF IBDOpen THEN
											state := MotorizedIBDStates.Initialized;
										END_IF
	
	
	MotorizedIBDStates.Initialized :			//
										state := MotorizedIBDStates.Idle;
	
	
	MotorizedIBDStates.MoveJawOut :			//
										
										//IBDMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
										IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
										state := MotorizedIBDStates.MovingJawOut;
										_openIBD := FALSE;
										//IBDMotor.SetPositionLimit(150);
	
	MotorizedIBDStates.MovingJawOut :			//
										IF IBDOpen THEN
											state := MotorizedIBDStates.Idle;
										END_IF
	
	
	MotorizedIBDStates.MovedJawOut :			//
										
	
	MotorizedIBDStates.MoveOutFull :			//
										
										//IBDMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
										IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
										state := MotorizedIBDStates.MovingOutFull;
										//IBDMotor.SetPositionLimit(150);
	
	MotorizedIBDStates.MovingOutFull :			//
										IF IBDOpen THEN
											state := MotorizedIBDStates.Idle;
										END_IF
	
	
	MotorizedIBDStates.MovedOutFull :			//
	
	MotorizedIBDStates.MoveJawIn :				//
									
										IBDMotor.MoveToPositionTorque(inPositionSetting,accel,decel,velo,testCurrent);
										//IBDMotor.MoveToPosition(0,accel,decel,velo+(TO_INT(TO_REAL(velo)*0.25)));
										state := MotorizedIBDStates.MovingJawIn;
	
	
	MotorizedIBDStates.MovingJawIn : 			//
										IF IBDMotor.alarms.currentFoldback OR IBDMotor.InPosition THEN
											state := MotorizedIBDStates.Clamping;
										END_IF
	
	
	MotorizedIBDStates.MovedJawIn :			//
										state := MotorizedIBDStates.StartClamping;
	
	
	MotorizedIBDStates.StartClamping :			//
										
	
	MotorizedIBDStates.StartedClamping :		//
										
	
	
	MotorizedIBDStates.Clamping :				//
										IF _openIBD THEN
											_openIBD := FALSE;
											state := MotorizedIBDStates.MoveJawOut;
										END_IF
											
										IF _openFull THEN
											_openFull := FALSE;
											state := MotorizedIBDStates.MoveOutFull;
										END_IF
	
	
	MotorizedIBDStates.ReleaseClamp :			//  
										
	
	MotorizedIBDStates.ReleasingClamp :		//
										
	
	MotorizedIBDStates.Faulting :			// 
										Globals.jawMovingIn := FALSE;
										_reset := FALSE;
										_openIBD := FALSE;
										_closeIBD := FALSE;
										_homeNow := FALSE;
										startTest := FALSE;
										testActive := FALSE;
										delayTimer.IN := FALSE;
										//IBDMotor.MoveDistanceTorque(velocity:=100, acceleration := 1, deceleration := 1, distance := 0, current := 0);
										IBDMotor.Disable();
										state := MotorizedIBDStates.Faulted;
	
	MotorizedIBDStates.Faulted :				//
	
	


END_CASE
	
feedbackHandler(
	extendedFeedbackInput:= IBDOpen OR IBDFullyOpen, 
	retractedFeedbackInput:= , 
	extendOutput:= state = MotorizedIBDStates.MovingJawOut, 
	retractOutput:= state = MotorizedIBDStates.MovingJawIn, 
	extendFaultDelay:= 3000 , 
	retractFaultDelay:= 3000 , 
	faultMonitoring:= (state = MotorizedIBDStates.MovingJawOut) OR (state = MotorizedIBDStates.MovingOutFull), 
	failedToExtend=> failToOpen.faultTrigger, 
	failedToRetract=> );
SUPER^();