(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedPressureBar EXTENDS BaseComponentFB
VAR_INPUT
	iPressureBarClamped: BOOL;
	iPressureBarClosed : BOOL;
	iPressureBarNotObstructed : BOOL;
	iBaggerEnableButton : BOOL;
	iJawClampLeftExtended : BOOL;
	iJawCLampLeftRetracted : BOOL;
	iJawClampRightExtended : BOOL;
	iJawClampRightRetracted : BOOL;
	pbarOutSetting : REAL := 12.0;
	pbarInSetting : REAL;
	closeDelay : REAL;
	disableFaults : BOOL;
	extendJawClamp : BOOL;
	retractJawClamp : BOOL;
	extendJaw : BOOL;
	retractJaw : BOOL;
END_VAR
VAR_OUTPUT
	obstructionFault : FB_Fault(name := 'Pbar Obstruction Fault');
	failToClose : FB_Fault(name := 'Pbar Fail to Close');
	failToOpen : FB_Fault(name := 'Pbar Fail to Open');
	failToClampLeft : FB_Fault(name := 'Pbar Left Fail to Clamp');
	failToReleaseLeft : FB_Fault(name := 'Pbar Left Fail to Release');
	failToClampRight : FB_Fault(name := 'Pbar Right Fail to Clamp');
	failToReleaseRight : FB_Fault(name := 'Pbar Right Fail to Release');
	state : MotorizedPbarStates;
	actualPosition : REAL;
	IBDOpen : BOOL;
	pressureBarOpen : BOOL;
	homeRequired : BOOL;
	clamped : BOOL;
END_VAR
VAR
	_homeNow : BOOL;
	_openJaw : BOOL;
	_openIBD : BOOL;
	_closeJaw : BOOL;
	_closeIBD : BOOL;
	accel : INT := 300;
	decel : INT := 300;
	velo : INT := 2000;
	testCurrent : DINT := 200;
	testZeroCurrent : BOOL;
	testSomeCurrent : BOOL;
	testClamp : BOOL;
	testRelease : BOOL;
	pbarFeedbackHandler : FB_CylinderFeedback;
	jawClampsLeftFeedbackHandler : FB_CylinderFeedback;
	jawClampsRightFeedbackHandler : FB_CylinderFeedback;
	startTest : BOOL;
	testActive : BOOL;
	movePassthroughNow : BOOL;
	delayTimer : Standard.TON := (PT:= T#500MS);
END_VAR
VAR_IN_OUT
	jawClamps : FB_ThreePositionCylinder;
	pbarMotor : FB_AppliedMotionStepServoEIPPassthrough;
	//IBDMotor : FB_AppliedMotionStepServoEIPPassthrough;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

actualPosition := pbarMotor.absolutePositonInches;
pressureBarOpen := pbarMotor.InPosition;
//IBDOpen := TO_DINT(IBDMotor.absolutePositonInches) = TO_DINT(pbarOutSetting);
delayTimer();

clamped := state = MotorizedPbarStates.Clamping;

pbarFeedbackHandler(
	extendedFeedbackInput:= pressureBarOpen, 
	retractedFeedbackInput:= iPressureBarClosed, 
	extendOutput:= , 
	retractOutput:= , 
	extendFaultDelay:= 1500, 
	retractFaultDelay:= 1500, 
	faultMonitoring:= NOT disableFaults, 
	failedToExtend=> failToOpen.faultTrigger, 
	failedToRetract=> failToClose.faultTrigger);

jawClampsLeftFeedbackHandler(
	extendedFeedbackInput:= iJawClampLeftExtended, 
	retractedFeedbackInput:= iJawCLampLeftRetracted, 
	extendOutput:= jawClamps.extendOutput, 
	retractOutput:= jawClamps.retractOutput, 
	extendFaultDelay:= 1000, 
	retractFaultDelay:= 1000, 
	faultMonitoring:= NOT disableFaults, 
	failedToExtend=> failToReleaseLeft.faultTrigger, 
	failedToRetract=> failToClampLeft.faultTrigger);

jawClampsRightFeedbackHandler(
	extendedFeedbackInput:= iJawClampRightExtended, 
	retractedFeedbackInput:= iJawCLampRightRetracted, 
	retractOutput:= jawClamps.retractOutput, 
	extendOutput:= jawClamps.extendOutput, 
	extendFaultDelay:= 1000, 
	retractFaultDelay:= 1000, 
	faultMonitoring:= NOT disableFaults, 
	failedToExtend=> failToReleaseRight.faultTrigger, 
	failedToRetract=> failToClampRight.faultTrigger);


IF extendJawClamp THEN
	extendJawClamp := FALSE;
	jawClamps.Extend();
ELSIF retractJawClamp THEN
	retractJawClamp := FALSE;
	jawClamps.Retract();
END_IF

IF NOT pbarMotor.HomeRequired THEN
	IF extendJaw THEN
		extendJaw := FALSE;
		pbarMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
	ELSIF retractJaw THEN
		retractJaw := FALSE;
		pbarMotor.MoveToPositionTorque(pbarInSetting,accel,decel,velo,testCurrent);
	END_IF
END_IF

IF testClamp THEN
	pbarMotor.AllowClamping();
	testClamp := FALSE;
END_IF

IF testRelease THEN
	pbarMotor.DoneClamping();
	testRelease := FALSE;
END_IF

IF testZeroCurrent THEN
	pbarMotor.SetTorque(0);
	testZeroCurrent := FALSE;
END_IF

IF testSomeCurrent THEN
	pbarMotor.SetTorque(testCurrent);
	testSomeCurrent := FALSE;
END_IF


IF _reset THEN
	pbarMotor.Reset();
	//IBDMotor.Reset();
	Globals.jawMovingIn := FALSE;
	_reset := FALSE;
	startTest := FALSE;
	testActive := FALSE;
	delayTimer.IN := FALSE;
	pbarFeedbackHandler.extendOutput := FALSE;
	pbarFeedbackHandler.retractOutput := FALSE;
	state := MotorizedPbarStates.Idle; 
END_IF

IF 	(	pbarMotor.Faulted AND NOT disableFaults)
	OR (pbarFeedbackHandler.faultIndication
	OR jawClampsLeftFeedbackHandler.faultIndication
	OR jawClampsRightFeedbackHandler.faultIndication)
	AND state <> MotorizedPbarStates.Faulted
THEN
	state := MotorizedPbarStates.Faulting; 
END_IF

IF pbarMotor.homeRequired THEN
	homeRequired := TRUE;
END_IF

_ready := state = MotorizedPbarStates.Idle AND NOT homeRequired AND pressureBarOpen;

CASE state OF
	MotorizedPbarStates.Idle :					//
										IF startTest THEN
											startTest := FALSE;
											testActive := TRUE;
											IF pbarMotor.homeRequired THEN
												pbarMotor.HomeNow();
												state := MotorizedPbarStates.Homing;
											ELSE
												state := MotorizedPbarStates.Initialize;
											END_IF
												
										END_IF
											
										IF _homeNow THEN
											_homeNow := FALSE;
											pbarMotor.HomeNow();
											state := MotorizedPbarStates.Homing;
										END_IF
										
										IF _openJaw THEN
											_openJaw := FALSE;
											state := MotorizedPbarStates.MoveJawOut;
										END_IF
										
										IF _closeJaw THEN
											_closeJaw := FALSE;
											state := MotorizedPbarStates.MoveJawIn;
										END_IF
	
	MotorizedPbarStates.Homing :				//
										Globals.jawMovingIn := TRUE;
										IF NOT (pbarMotor.homeRequired) THEN
												pbarMotor.DoneClamping();
												homeRequired := FALSE;
												state := MotorizedPbarStates.Initialize;
										END_IF
	
	
	MotorizedPbarStates.Initialize :			//
										Globals.jawMovingIn := TRUE;
										IF pressureBarOpen AND IBDOpen THEN
											state := MotorizedPbarStates.Initialized;
										ELSE
											jawClamps.Extend();
											pbarMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
											//IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
											state := MotorizedPbarStates.Initializing;
										END_IF
	
	
	MotorizedPbarStates.Initializing :			//
										IF pressureBarOpen AND IBDOpen THEN
											state := MotorizedPbarStates.Initialized;
										END_IF
	
	
	MotorizedPbarStates.Initialized :			//
										state := MotorizedPbarStates.Idle;
	
	
	MotorizedPbarStates.MoveJawOut :			//
										
										Globals.jawMovingIn := FALSE;
										pbarMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
										//IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
										state := MotorizedPbarStates.MovingJawOut;
										//pbarMotor.SetPositionLimit(150);
	
	MotorizedPbarStates.MovingJawOut :			//
										IF pressureBarOpen THEN
											state := MotorizedPbarStates.Idle;
										END_IF
	
	
	MotorizedPbarStates.MovedJawOut :			//
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											state := MotorizedPbarStates.MoveJawIn;
										END_IF
	
	
	MotorizedPbarStates.MoveJawIn :				//
										Globals.jawMovingIn := TRUE;
										pbarMotor.MoveToPositionTorque(pbarInSetting,accel,decel,velo,testCurrent);
										//IBDMotor.MoveToPosition(0,accel,decel,velo+(TO_INT(TO_REAL(velo)*0.25)));
										
										state := MotorizedPbarStates.MovingJawIn;
	
	
	MotorizedPbarStates.MovingJawIn : 			//
										IF iPressureBarClosed THEN
											pbarMotor.AllowClamping();
											state := MotorizedPbarStates.MovedJawIn;
										END_IF
	
	
	MotorizedPbarStates.MovedJawIn :			//
										state := MotorizedPbarStates.StartClamping;
	
	
	MotorizedPbarStates.StartClamping :			//
										//pbarMotor.SetPositionLimit(20000);
										jawClamps.Retract();
										state := MotorizedPbarStates.StartedClamping;
	
	MotorizedPbarStates.StartedClamping :		//
										IF iPressureBarClamped THEN
											state := MotorizedPbarStates.Clamping;	
										END_IF
	
	
	MotorizedPbarStates.Clamping :				//
										IF _openJaw THEN
											state := MotorizedPbarStates.ReleaseClamp;
										END_IF
	
	
	
	MotorizedPbarStates.ReleaseClamp :			//  
										jawClamps.Extend();
										pbarMotor.DoneClamping();
										state := MotorizedPbarStates.ReleasingClamp;
	
	
	MotorizedPbarStates.ReleasingClamp :		//
										IF iJawClampLeftExtended AND iJawClampRightExtended THEN
											
											state := MotorizedPbarStates.MoveJawOut;
											//HMI.data.TFBeltPressureBarCycles := HMI.data.TFBeltPressureBarCycles + 1;
										END_IF
	
	MotorizedPbarStates.Faulting :			// 
										Globals.jawMovingIn := FALSE;
										_reset := FALSE;
										_openJaw := FALSE;
										_closeJaw := FALSE;
										_homeNow := FALSE;
										startTest := FALSE;
										testActive := FALSE;
										delayTimer.IN := FALSE;
										pbarFeedbackHandler.extendOutput := FALSE;
										pbarFeedbackHandler.retractOutput := FALSE;
										pbarMotor.MoveDistanceTorque(velocity:=100, acceleration := 1, deceleration := 1, distance := 0, current := 0);
										//IBDMotor.Disable();
										state := MotorizedPbarStates.Faulted;
	
	MotorizedPbarStates.Faulted :				//
	
END_CASE

IF Globals.jawMovingIn AND NOT disableFaults THEN
	IF NOT iPressureBarNotObstructed AND NOT iPressureBarClosed THEN
		obstructionFault.Trigger();
		state := MotorizedPbarStates.Faulting;
	END_IF
END_IF

