(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedPressureBar EXTENDS BaseComponentFB
VAR_INPUT
	iPressureBarClamped: BOOL;
	iPressureBarClosed : BOOL;
	iPressureBarNotObstructed : BOOL;
	iBaggerEnableButton : BOOL;
	iJawClampExtended : BOOL;
	iJawCLampRetracted : BOOL;
	pbarOutSetting : REAL := 12.0;
	pbarInSetting : REAL := 0.03;
	closeDelay : REAL;
	disableFaults : BOOL;
	extendJawClamp : BOOL;
	retractJawClamp : BOOL;
	extendJaw : BOOL;
	retractJaw : BOOL;
END_VAR
VAR_OUTPUT
	
	
	failToClampLeft : FB_Fault(name := 'Pbar Left Fail to Clamp');
	failToReleaseLeft : FB_Fault(name := 'Pbar Left Fail to Release');
	failToClampRight : FB_Fault(name := 'Pbar Right Fail to Clamp');
	failToReleaseRight : FB_Fault(name := 'Pbar Right Fail to Release');
	faults : PressureBarFaultsType;
	state : MotorizedPbarStates;
	actualPosition : REAL;
	pressureBarOpen : BOOL;
	pressureBarClosed : BOOL;
	homeRequired : BOOL;
	clamped : BOOL;
END_VAR
VAR
	_homeNow : BOOL;
	_openJaw : BOOL;
	_closeJaw : BOOL;
	_closeJawNoLatch : BOOL;
	jawClampsDelay : TIME := T#75ms;
	accel : INT := 40;
	decel : INT := 60;
	velo : INT := 1250;
	testCurrent : DINT := 500;
	testZeroCurrent : BOOL;
	testSomeCurrent : BOOL;
	testClamp : BOOL;
	testRelease : BOOL;
	testPosLimit : BOOL;
	testDisable : BOOL;
	testEnable : BOOL;
	testResetPosition : BOOL;
	posLimit : DINT := 3000;
	pbarFeedbackHandler : FB_CylinderFeedback;
	jawClampsLeftFeedbackHandler : FB_CylinderFeedback;
	jawClampsRightFeedbackHandler : FB_CylinderFeedback;
	startTest : BOOL;
	testActive : BOOL;
	movePassthroughNow : BOOL;
	delayTimer : Standard.TON := (PT:= T#500MS);
	failTimer : Standard.TON := (PT:= T#500MS);
	homeRequiredONS : FB_ONS;
	faultingONS : FB_ONS;
	faultTimeMultiplier : REAL := 150;
	distanceToMove : REAL;
END_VAR
VAR_IN_OUT
	jawClamps : FB_ThreePositionCylinder;
	pbarMotor : FB_AppliedMotionStepServoEIPPassthrough;
	//IBDMotor : FB_AppliedMotionStepServoEIPPassthrough;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

actualPosition := pbarMotor.absolutePositonInches;
pressureBarOpen := TO_DINT(actualPosition * 1000) >= (TO_DINT(pbarOutSetting * 1000) - 10) AND TO_DINT(actualPosition * 1000) <= (TO_DINT(pbarOutSetting * 1000) + 10);
//pressureBarClosed := pbarMotor.absolutePositionSteps >= (pbarMotor.distanceToMoveInSteps - 4) AND pbarMotor.absolutePositionSteps <= (pbarMotor.distanceToMoveInSteps + 4);
pressureBarClosed := iPressureBarClosed;
delayTimer();
failTimer(IN := (state = MotorizedPbarStates.StartedClamping) AND (NOT (iJawCLampRetracted AND iPressureBarClamped AND iPressureBarClosed)));
clamped := state = MotorizedPbarStates.Clamping;





// jawClampsLeftFeedbackHandler(
// 	extendedFeedbackInput:= iJawClampLeftExtended, 
// 	retractedFeedbackInput:= iJawCLampLeftRetracted, 
// 	extendOutput:= jawClamps.extendOutput, 
// 	retractOutput:= jawClamps.retractOutput, 
// 	extendFaultDelay:= 1000, 
// 	retractFaultDelay:= 1000, 
// 	faultMonitoring:= NOT disableFaults, 
// 	failedToExtend=> failToReleaseLeft.faultTrigger, 
// 	failedToRetract=> failToClampLeft.faultTrigger);
// 
// jawClampsRightFeedbackHandler(
// 	extendedFeedbackInput:= iJawClampRightExtended, 
// 	retractedFeedbackInput:= iJawCLampRightRetracted, 
// 	retractOutput:= jawClamps.retractOutput, 
// 	extendOutput:= jawClamps.extendOutput, 
// 	extendFaultDelay:= 1000, 
// 	retractFaultDelay:= 1000, 
// 	faultMonitoring:= NOT disableFaults, 
// 	failedToExtend=> failToReleaseRight.faultTrigger, 
// 	failedToRetract=> failToClampRight.faultTrigger);


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

IF testDisable THEN
	pbarMotor.Disable();
	testDisable := FALSE;
END_IF

IF testEnable THEN
	pbarMotor.Enable();
	testEnable := FALSE;
END_IF

IF testClamp THEN
	pbarMotor.AllowClamping();
	testClamp := FALSE;
END_IF

IF testRelease THEN
	pbarMotor.DoneClamping();
	testRelease := FALSE;
END_IF

IF testResetPosition THEN
	pbarMotor.ResetEncoderPosition(pbarMotor.driveInputs[5]);
	testResetPosition := FALSE;
END_IF

IF testZeroCurrent THEN
	pbarMotor.MoveDistanceTorque(velocity:=100, acceleration := 1, deceleration := 1, distance := 0, current := 1);
	//pbarMotor.SetTorque(1);
	testZeroCurrent := FALSE;
END_IF

IF testSomeCurrent THEN
	pbarMotor.SetTorque(testCurrent);
	testSomeCurrent := FALSE;
END_IF

IF testPosLimit THEN
	pbarMotor.SetPositionLimit(posLimit);
	testPosLimit := FALSE;
END_IF

IF resetONS.Q THEN
	pbarMotor.Reset();
	//pbarMotor.Enable();
	
	//IBDMotor.Reset();
	Globals.jawMovingIn := FALSE;
	_reset := FALSE;
	startTest := FALSE;
	testActive := FALSE;
	delayTimer.IN := FALSE;
	pbarMotor.DoneClamping();
	jawClamps.Extend();
	pbarFeedbackHandler.extendOutput := FALSE;
	pbarFeedbackHandler.retractOutput := FALSE;
	state := MotorizedPbarStates.Idle; 
END_IF
faultingONS(CLK := (	pbarMotor.Faulted AND NOT disableFaults)
	OR (pbarFeedbackHandler.faultIndication
	OR jawClampsLeftFeedbackHandler.faultIndication
	OR jawClampsRightFeedbackHandler.faultIndication
	OR faults.obstructionDetected.active));

IF 	faultingONS.OSR
	AND state <> MotorizedPbarStates.Faulted 
THEN
	state := MotorizedPbarStates.Faulting; 
END_IF

homeRequiredONS(CLK := pbarMotor.homeRequired);
IF homeRequiredONS.OSR THEN
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
											//IF (pbarMotor.homeRequired) THEN
												pbarMotor.HomeNow();
											//END_IF
											delayTimer.PT := T#150MS;
											delayTimer.IN := TRUE;
											state := MotorizedPbarStates.Homing;
										END_IF
										
										IF _openJaw AND NOT _reset THEN
											//pbarMotor.DoneClamping();
											_openJaw := FALSE;
											state := MotorizedPbarStates.MoveJawOut;
										END_IF
										
										IF _closeJaw THEN
											_closeJaw := FALSE;
											state := MotorizedPbarStates.MoveJawIn;
										END_IF
										
										IF _closeJawNoLatch THEN
											//_closeJawNoLatch := FALSE;
											state := MotorizedPbarStates.MoveJawIn;
										END_IF
	
	MotorizedPbarStates.Homing :				//
										Globals.jawMovingIn := TRUE;
										IF NOT (pbarMotor.homeRequired) AND delayTimer.Q THEN
												delayTimer.IN := FALSE;
												//pbarMotor.DoneClamping();
												
												homeRequired := FALSE;
												
												state := MotorizedPbarStates.Initialize;
										END_IF
	
	
	MotorizedPbarStates.Initialize :			//
										delayTimer.PT := T#500MS;
										delayTimer.IN := TRUE;
										Globals.jawMovingIn := TRUE;
										IF delayTimer.Q THEN
											IF pressureBarOpen THEN
												state := MotorizedPbarStates.Initialized;
											ELSE
												jawClamps.Extend();
												pbarMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
												//IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
												state := MotorizedPbarStates.Initializing;
											END_IF
											delayTimer.IN := FALSE;
										END_IF
										
	
	
	MotorizedPbarStates.Initializing :			//
										IF pressureBarOpen THEN
											state := MotorizedPbarStates.Initialized;
										END_IF
	
	
	MotorizedPbarStates.Initialized :			//
										IF testActive THEN
											state := MotorizedPbarStates.MoveJawIn;
										ELSE
											state := MotorizedPbarStates.Idle;
										END_IF
										
	
	
	MotorizedPbarStates.MoveJawOut :			//
										
										Globals.jawMovingIn := FALSE;
										pbarMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,testCurrent);
										//IBDMotor.MoveToPosition(pbarOutSetting,accel,decel,velo);
										distanceToMove := ABS(actualPosition - pbarOutSetting);
										state := MotorizedPbarStates.MovingJawOut;
										//pbarMotor.SetPositionLimit(150);
	
	MotorizedPbarStates.MovingJawOut :			//
										IF pressureBarOpen THEN
											
											IF testActive THEN
												delayTimer.PT := T#500MS;
												delayTimer.IN := TRUE;
												IF delayTimer.Q  THEN
													delayTimer.IN := FALSE;
													state := MotorizedPbarStates.MoveJawIn;
												END_IF
											ELSE
												delayTimer.PT := T#100MS;
												delayTimer.IN := TRUE;
												IF delayTimer.Q  THEN
													//pbarMotor.ResetEncoderPosition(pbarMotor.driveInputs[5]);
													delayTimer.IN := FALSE;
													state := MotorizedPbarStates.Idle;
												END_IF
											END_IF
										END_IF
	
	
	MotorizedPbarStates.MovedJawOut :			//
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											state := MotorizedPbarStates.MoveJawIn;
										END_IF
	
	
	MotorizedPbarStates.MoveJawIn :				//
										Globals.jawMovingIn := TRUE;
										pbarMotor.MoveToPositionTorque(pbarInSetting,accel,decel,velo,testCurrent);
										//pbarMotor.MoveToPositionTorque(pbarInSetting,accel,decel,velo,testCurrent);
										//IBDMotor.MoveToPosition(0,accel,decel,velo+(TO_INT(TO_REAL(velo)*0.25)));
										distanceToMove := ABS(actualPosition - pbarInSetting);
										state := MotorizedPbarStates.MovingJawIn;
	
	
	MotorizedPbarStates.MovingJawIn : 			//
										//IF iPressureBarClosed AND pbarMotor.absolutePositonInches = 0 THEN
										IF iPressureBarClosed THEN
											IF NOT  _closeJawNoLatch THEN
												pbarMotor.AllowClamping();
											END_IF
											
											delayTimer.PT := jawClampsDelay;
											delayTimer.IN := TRUE;
											//pbarMotor.Disable();
											state := MotorizedPbarStates.MovedJawIn;
										END_IF
	
	
	MotorizedPbarStates.MovedJawIn :			//
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											IF _closeJawNoLatch THEN
												_closeJawNoLatch := FALSE;
												state := MotorizedPbarStates.Idle;
											ELSE
												state := MotorizedPbarStates.StartClamping;
											END_IF
										END_IF
										
	
	
	MotorizedPbarStates.StartClamping :			//
										//pbarMotor.SetPositionLimit(20000);
										jawClamps.Retract();
										state := MotorizedPbarStates.StartedClamping;
	
	MotorizedPbarStates.StartedClamping :		//
										IF iPressureBarClamped AND iJawClampsRetracted THEN
											delayTimer.PT := T#250MS;
											delayTimer.IN := TRUE;
											IF delayTimer.Q THEN
												pbarMotor.ResetEncoderPosition(pbarMotor.driveInputs[5]);
												state := MotorizedPbarStates.Clamping;	
											END_IF
										END_IF
										
										
										IF testActive THEN
											delayTimer.PT := T#2S;
											delayTimer.IN := TRUE;
										END_IF
	
	
	MotorizedPbarStates.Clamping :				//
										IF _openJaw OR (testActive AND delayTimer.Q) THEN
											_openJaw := FALSE;
											delayTimer.IN := FALSE;
											jawClamps.Extend();
											state := MotorizedPbarStates.ReleaseClamp;
										END_IF
										
	
	
	
	MotorizedPbarStates.ReleaseClamp :			//  
										IF iJawClampExtended THEN
											pbarMotor.DoneClamping();
											//pbarMotor.Enable();
											delayTimer.PT := jawClampsDelay;
											delayTimer.IN := TRUE;
											state := MotorizedPbarStates.ReleasingClamp;
										END_IF
										
	
	
	MotorizedPbarStates.ReleasingClamp :		//
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											state := MotorizedPbarStates.MoveJawOut;
											//HMI.data.TFBeltPressureBarCycles := HMI.data.TFBeltPressureBarCycles + 1;
										END_IF
	
	MotorizedPbarStates.Faulting :			// 
										Globals.jawMovingIn := FALSE;
										_reset := FALSE;
										_openJaw := FALSE;
										_closeJaw := FALSE;
										_homeNow := FALSE;
										_closeJawNoLatch := FALSE;
										startTest := FALSE;
										testActive := FALSE;
										delayTimer.IN := FALSE;
										jawClamps.Extend();
										pbarFeedbackHandler.extendOutput := FALSE;
										pbarFeedbackHandler.retractOutput := FALSE;
										pbarMotor.Disable();
										//IBDMotor.Disable();
										state := MotorizedPbarStates.Faulted;
			
	MotorizedPbarStates.Faulted :				//
	
END_CASE


IF pbarMotor.alarms.positionLimit OR failTimer.Q THEN
	faults.obstructionDetected.faultTrigger := TRUE;
	homeRequired := TRUE;
	//state := MotorizedPbarStates.Faulting;
ELSE
	faults.obstructionDetected.faultTrigger := FALSE;
END_IF

pbarFeedbackHandler(
	extendedFeedbackInput:= pressureBarOpen, 
	retractedFeedbackInput:= iPressureBarClosed, 
	extendOutput:= state = MotorizedPbarStates.MovingJawOut, 
	retractOutput:= state = MotorizedPbarStates.MovingJawIn, 
	extendFaultDelay:= 3000 , 
	retractFaultDelay:= 3000 , 
	faultMonitoring:= distanceToMove > 0.5, 
	failedToExtend=> faults.failedToOpen.faultTrigger, 
	failedToRetract=> faults.failedToClose.faultTrigger);
	
SUPER^();
