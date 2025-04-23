(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MotorizedPressureBarRubberband EXTENDS FB_BaseComponent
VAR_INPUT
	jawClear :BOOL := TRUE;
	openedPositionBuffer : DINT;
	iPressureBarClamped: BOOL;
	iPressureBarClosed : BOOL;
	iPressureBarNotObstructed : BOOL;
	iBaggerEnableButton : BOOL;
	iJawClampExtended : BOOL;
	iJawCLampRetracted : BOOL;
	pbarOutSetting : REAL := 12.0;
	pbarBagFeedSetting : REAL := 2.0;
	pbarInSetting : REAL := 0.0;
	closeDelay : REAL;
	disableFaults : BOOL;
	extendJawClamp : BOOL;
	retractJawClamp : BOOL;
	extendJaw : BOOL;
	retractJaw : BOOL;
	enableRubberBandJaw : BOOL;
	slowAccel : INT := 50;
	slowVel : INT := 1000;
	slowOpenThreshold : int := 6;
END_VAR
VAR_OUTPUT
	
	
	failToClampLeft : FB_Fault(name := 'Pbar Left Fail to Clamp');
	failToReleaseLeft : FB_Fault(name := 'Pbar Left Fail to Release');
	failToClampRight : FB_Fault(name := 'Pbar Right Fail to Clamp');
	failToReleaseRight : FB_Fault(name := 'Pbar Right Fail to Release');
	faults : PressureBarFaultsType;
	state : MotorizedPbarStatesRubberBand;
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
	_openForBagFeed : BOOL;
	_nextState : MotorizedPbarStatesRubberBand;
	jawClampsDelay : TIME := T#75MS;
	retryOpenDelay : TON := (PT:= T#500MS);
	accel : INT := 75;
	decel : INT := 75;
	velo : INT := 2000;
	clearVelo: INT := 1000;
	testCurrent : DINT := 650;
	testZeroCurrent : BOOL;
	testSomeCurrent : BOOL;
	testClamp : BOOL;
	testRelease : BOOL;
	testPosLimit : BOOL;
	testDisable : BOOL;
	testEnable : BOOL;
	testResetPosition : BOOL;
	posLimit : DINT := 800;
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
	disableMotorONS : FB_ONS;
	pbarOutCommandedSetting : REAL := 2;
	strokeTimer : Standard.TON;
	strokeTime : TIME;
	movingONS : FB_ONS;
	doneClampingDelay : Standard.TON := (PT := T#50MS);
	pressureBarPositionError : DINT;
	movingOSF: f_trig;
	_incrementalReverse:BOOL := FALSE;
	_incrementalReverseDistance : REAL := 0.0;
	_moveJawClear: BOOL;
	retrycount: INT;
	_positionFaultLimit : INT;
	_motorCurrent : DINT;
END_VAR
VAR_IN_OUT
	jawClamps : FB_ThreePositionCylinder;
	pbarMotor : FB_AppliedMotionStepServoEIPPassthrough;
END_VAR
VAR CONSTANT
	MOTOR_CURRRENT_HIGH : DINT := 650;
	MOTOR_CURRENT_LOW : DINT := 200;
	POSITION_FAULT_LIMIT_STANDARD : INT := 2000;
	POSITION_FAULT_LIMIT_HIGH : INT := 24000;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//Modified to ensure that PBAR motor syncs with encoder after each move. CT
//movingOSF(CLK:= pbarmotor.status.moving);
movingOSF(CLK:= pressureBarOpen);
IF (pbarmotor.driveInputs[5] <> pbarmotor.driveInputs[6]+100) AND movingOSF.Q THEN
	//pbarmotor.ResetEncoderPosition(pbarmotor.driveinputs[5]);
END_IF
//
actualPosition := pbarMotor.absolutePositonInches;

// Absolutle difference of actual vs commanded pressure bar position
pressureBarPositionError := ABS(TO_DINT((actualPosition - pbarOutCommandedSetting) * 1000));

// Check is pressure bar open position is within buffer threshold  
pressureBarOpen := pressureBarPositionError < openedPositionBuffer;

delayTimer();
retryOpenDelay();
pressureBarClosed := iPressureBarClosed;
failTimer(IN := ((state = MotorizedPbarStatesRubberBand.StartedClamping)AND (NOT (iJawCLampRetracted AND iPressureBarClosed)))
				OR ((state = MotorizedPbarStatesRubberBand.ReleaseClamp)AND NOT iJawClampExtended)
		);
		
clamped := state = MotorizedPbarStatesRubberBand.Clamping;

strokeTimer();
movingONS(CLK := state = MotorizedPbarStatesRubberBand.MovingJawIn);

IF movingONS.OSR THEN
	strokeTimer.IN := TRUE;
END_IF
IF movingONS.OSF THEN
	strokeTime := strokeTimer.ET;
	strokeTimer.IN := FALSE;
END_IF
	

disableMotorONS(CLK := clamped AND (iPressureBarClamped and not hmidata.enablePerfBreaker) AND iJawClampsRetracted);
IF disableMotorONS.OSR THEN
	pbarMotor.AllowClamping();
END_IF



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
	pbarMotor.SetPositionFaultLimit(posLimit);
	testPosLimit := FALSE;
END_IF

doneClampingDelay();

IF resetONS.Q THEN
	pbarOutCommandedSetting := pbarOutSetting;
	pbarMotor.Reset();
	//pbarMotor.Enable();
	pbarMotor.ResetEncoderPosition(pbarMotor.driveInputs[5]);
	//IBDMotor.Reset();
	Globals.jawMovingIn := FALSE;
	_reset := FALSE;
	_openJaw := FALSE;
	startTest := FALSE;
	testActive := FALSE;
	delayTimer.IN := FALSE;
	jawClamps.Extend();
	pbarFeedbackHandler.extendOutput := FALSE;
	pbarFeedbackHandler.retractOutput := FALSE;
	doneClampingDelay.IN := TRUE;
	state := MotorizedPbarStatesRubberBand.Idle; 
END_IF

IF doneClampingDelay.Q THEN
	pbarMotor.DoneClamping();
	doneClampingDelay.IN := FALSE;
END_IF

faultingONS(CLK := (	pbarMotor.Faulted AND NOT disableFaults)
	OR (pbarFeedbackHandler.faultIndication
	OR jawClampsLeftFeedbackHandler.faultIndication
	OR jawClampsRightFeedbackHandler.faultIndication
	OR faults.obstructionDetected.active));

IF 	faultingONS.OSR
	AND state <> MotorizedPbarStatesRubberBand.Faulted 
THEN
	state := MotorizedPbarStatesRubberBand.Faulting; 
END_IF

homeRequiredONS(CLK := pbarMotor.homeRequired);
IF homeRequiredONS.OSR THEN
	homeRequired := TRUE;
END_IF

_ready := state = MotorizedPbarStatesRubberBand.Idle AND NOT homeRequired AND pressureBarOpen;

CASE state OF
	MotorizedPbarStatesRubberBand.Idle :					//
										//Test Reset encoder and motor										
										IF startTest THEN
											startTest := FALSE;
											testActive := TRUE;
											IF pbarMotor.homeRequired THEN
												pbarMotor.HomeNow();
												state := MotorizedPbarStatesRubberBand.Homing;
											ELSE
												state := MotorizedPbarStatesRubberBand.Initialize;
											END_IF
												
										END_IF
										IF _moveJawClear THEN
											state:= MotorizedPbarStatesRubberBand.MoveJawClear;
										END_IF
										IF _homeNow THEN
											_homeNow := FALSE;
											//IF (pbarMotor.homeRequired) THEN
												pbarMotor.HomeNow();
											//END_IF
											delayTimer.PT := T#150MS;
											delayTimer.IN := TRUE;
											state := MotorizedPbarStatesRubberBand.Homing;
										END_IF
										
										IF _openJaw THEN
											_openJaw := FALSE;
											_motorCurrent := MOTOR_CURRRENT_HIGH;
											pbarOutCommandedSetting := pbarOutSetting;
											state := MotorizedPbarStatesRubberBand.MoveJawOut;
										END_IF
										
										IF _openForBagFeed AND NOT _reset THEN
											_openForBagFeed := FALSE;
											_motorCurrent := MOTOR_CURRRENT_HIGH;
											pbarOutCommandedSetting := pbarBagFeedSetting;
											state := MotorizedPbarStatesRubberBand.MoveJawOut;
										END_IF
										
										IF _closeJaw THEN
											_closeJaw := FALSE;
											_motorCurrent := MOTOR_CURRRENT_HIGH;
											//IF enableRubberBandJaw THEN
												_positionFaultLimit := POSITION_FAULT_LIMIT_STANDARD;
												state := MotorizedPbarStatesRubberBand.PrepareToSetPositionLimit;
												_nextState := MotorizedPbarStatesRubberBand.MoveJawIn;
											//ELSE
											//	state := MotorizedPbarStatesRubberBand.MoveJawIn;
											//END_IF
										END_IF
										
										IF _closeJawNoLatch THEN
											_motorCurrent := MOTOR_CURRRENT_HIGH;
											_positionFaultLimit := POSITION_FAULT_LIMIT_STANDARD;
											state := MotorizedPbarStatesRubberBand.MoveJawIn;
										END_IF
	
	MotorizedPbarStatesRubberBand.Homing :				//
										Globals.jawMovingIn := TRUE;
										_homeNow := FALSE;
										IF NOT (pbarMotor.homeRequired OR homeRequired) AND delayTimer.Q THEN
												delayTimer.IN := FALSE;
												homeRequired := FALSE;
												state := MotorizedPbarStatesRubberBand.Initialize;
										ELSIF pbarMotor.HomeRequired OR homeRequired AND NOT pbarMotor.status.moving  THEN
											homeRequired := FALSE;
											 pbarMotor.HomeNow();
										END_IF
	
	
	MotorizedPbarStatesRubberBand.Initialize :			//
										delayTimer.PT := T#500MS;
										delayTimer.IN := TRUE;
										Globals.jawMovingIn := TRUE;
										IF delayTimer.Q THEN
											IF pressureBarOpen THEN
												pbarMotor.DoneClamping();
												state := MotorizedPbarStatesRubberBand.Initializing;
											ELSE
												jawClamps.Extend();
												pbarMotor.MoveToPositionTorque(pbarOutSetting,accel,decel,velo,_motorCurrent);
												state := MotorizedPbarStatesRubberBand.Initializing;
											END_IF
											delayTimer.IN := FALSE;
										END_IF
										
	
	
	MotorizedPbarStatesRubberBand.Initializing :			//
										IF _homeNow THEN

											//IF (pbarMotor.homeRequired) THEN
												pbarMotor.HomeNow();
											//END_IF
											delayTimer.PT := T#150MS;
											delayTimer.IN := TRUE;
											state := MotorizedPbarStatesRubberBand.Homing;

										ELSIF pressureBarOpen THEN
											state := MotorizedPbarStatesRubberBand.Initialized;

										END_IF
	
	
	MotorizedPbarStatesRubberBand.Initialized :			//
										IF testActive THEN
											state := MotorizedPbarStatesRubberBand.MoveJawIn;
										ELSE
											state := MotorizedPbarStatesRubberBand.Idle;
										END_IF
										
	MotorizedPbarStatesRubberBand.PrepareToSetPositionLimit:
			pbarMotor.SetPositionFaultLimit(_positionFaultLimit);
			state := MotorizedPbarStatesRubberBand.PreparingToSetPositionLimit;
		
	MotorizedPbarStatesRubberBand.PreparingToSetPositionLimit:
		IF pbarMotor.commandSuccessful THEN
			state := MotorizedPbarStatesRubberBand.PreparedSettingPositionLimit;
		END_IF
	
	MotorizedPbarStatesRubberBand.PreparedSettingPositionLimit:
		state := _nextState;
		_nextState := MotorizedPbarStatesRubberBand.Idle;
										
	MotorizedPbarStatesRubberBand.MoveJawOut:		
		//
										Globals.jawMovingIn := FALSE;
										delayTimer.IN := FALSE;
										
										IF pbarOutSetting > slowOpenThreshold THEN
											pbarMotor.MoveToPositionTorque(pbarOutCommandedSetting,slowAccel,decel,slowVel,_motorCurrent);
										ELSE 
											pbarMotor.MoveToPositionTorque(pbarOutCommandedSetting,accel,decel,velo,_motorCurrent);
										END_IF
										distanceToMove := ABS(actualPosition - pbarOutCommandedSetting);
										state := MotorizedPbarStatesRubberBand.MovingJawOut;
	
	MotorizedPbarStatesRubberBand.MoveJawClear : //
										delayTimer.PT := T#150MS;
										IF NOT jawClear AND NOT pbarMotor.Moving AND retrycount <=5 AND  homeRequired THEN
										_moveJawClear := FALSE;
										IF NOT delaytimer.in THEN

											delayTimer.IN := TRUE;
										ELSIF delayTimer.Q THEN
											pbarMotor.MoveDistance( 5,accel,decel,clearVelo);
											delayTimer.IN := FALSE;
											retrycount:= retrycount + 1;
										END_IF


										ELSIF jawClear THEN
											retrycount := 0;
											_moveJawClear := FALSE;
											pbarMotor.Stop();
											IF NOT pbarMotor.Moving THEN
											state := MotorizedPbarStatesRubberBand.Idle;
											delayTimer.IN := FALSE;
											END_IF


										ELSIF retrycount>5 THEN
												retrycount := 0;

											_moveJawClear := FALSE;
											pbarMotor.Stop();
											faults.failedToOpen.faultTrigger:=TRUE;
											delayTimer.IN := FALSE;
											state := MotorizedPbarStatesRubberBand.Idle;
										ELSIF NOT homeRequired THEN 
											state := MotorizedPbarStatesRubberBand.Initialize;

										END_IF

	MotorizedPbarStatesRubberBand.MovingJawOut :			//
										retryOpenDelay.IN := TRUE;
										IF retryOpenDelay.Q AND actualPosition < 0.3 THEN
										retryOpenDelay.IN := FALSE;
										state:= MotorizedPbarStatesRubberBand.MoveJawOut;
									END_IF
										IF pressureBarOpen AND NOT pbarMotor.status.moving THEN
											retryOpenDelay.IN := FALSE;																		
											IF testActive THEN
												delayTimer.PT := T#500MS;
												delayTimer.IN := TRUE;
												IF delayTimer.Q  THEN
													delayTimer.IN := FALSE;
													state := MotorizedPbarStatesRubberBand.MoveJawIn;
												END_IF
											ELSE
												delayTimer.PT := T#0MS;
												delayTimer.IN := TRUE;
												IF delayTimer.Q  THEN
													delayTimer.IN := FALSE;
													pbarmotor.ResetEncoderPosition(pbarmotor.driveinputs[5]);
													state := MotorizedPbarStatesRubberBand.ResettingEncoder;
												END_IF
											END_IF
										ELSIF NOT pbarMotor.status.moving AND NOT pressureBarOpen THEN  //Didn't make it. Try again!
												delayTimer.PT := T#100MS;
												delayTimer.IN := TRUE;
												IF delayTimer.Q  THEN
													IF pbarOutSetting > slowOpenThreshold THEN
														pbarMotor.MoveToPositionTorque(pbarOutCommandedSetting,slowAccel,decel,slowVel,_motorCurrent);
													ELSE 
														pbarMotor.MoveToPositionTorque(pbarOutCommandedSetting,accel,decel,velo,_motorCurrent);
													END_IF
													delayTimer.IN := FALSE;
													//state := MotorizedPbarStatesRubberBand.Idle;
												END_IF
											END_IF

	MotorizedPbarStatesRubberBand.ResettingEncoder :
										delayTimer.PT := T#50MS;
										delayTimer.IN := TRUE;
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											IF enableRubberBandJaw AND (pbarOutCommandedSetting = pbarOutSetting) THEN
												_positionFaultLimit := POSITION_FAULT_LIMIT_HIGH;
												state := MotorizedPbarStatesRubberBand.PrepareToSetPositionLimit;
												_nextState := MotorizedPbarStatesRubberBand.StartRubberBanding;
											ELSE
												state := MotorizedPbarStatesRubberBand.Idle;
											END_IF
											
										END_IF
	
	
	MotorizedPbarStatesRubberBand.MovedJawOut :			//
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											state := MotorizedPbarStatesRubberBand.MoveJawIn;
										END_IF
	
	MotorizedPbarStatesRubberBand.StartRubberBanding :
										pbarMotor.MoveToPositionTorque(pbarOutCommandedSetting, accel, decel, velo, MOTOR_CURRENT_LOW);
										state := MotorizedPbarStatesRubberBand.Idle;
	
	MotorizedPbarStatesRubberBand.MoveJawIn :				//
										Globals.jawMovingIn := TRUE;
										pbarMotor.MoveToPositionTorque(pbarInSetting, accel, decel, velo, _motorCurrent);
										distanceToMove := ABS(actualPosition - pbarInSetting);
										state := MotorizedPbarStatesRubberBand.MovingJawIn;
	
	MotorizedPbarStatesRubberBand.MovingJawIn : 			//
										
										IF iPressureBarClosed THEN
											IF NOT  _closeJawNoLatch THEN
												//pbarMotor.AllowClamping();
											END_IF
											
											delayTimer.PT := jawClampsDelay;

											delayTimer.IN := TRUE;
											state := MotorizedPbarStatesRubberBand.MovedJawIn;
										END_IF
	
	
	MotorizedPbarStatesRubberBand.MovedJawIn :			//

											delayTimer.IN := TRUE;
											// Need this delay for the 1183/1196 motors - not the 1182 though.
											IF delayTimer.Q OR HMIDAta.baggerModelSelection = ModelSelection.Pro24_1182 THEN

												delayTimer.IN := FALSE;
												IF _closeJawNoLatch THEN
													_closeJawNoLatch := FALSE;
													state := MotorizedPbarStatesRubberBand.Idle;
												ELSE
													state := MotorizedPbarStatesRubberBand.StartClamping;
												END_IF
											END_IF
	

	MotorizedPbarStatesRubberBand.StartClamping :			//
										// pbarMotor.SetPositionLimit(20000);

										jawClamps.Retract();
										state := MotorizedPbarStatesRubberBand.StartedClamping;
	
	MotorizedPbarStatesRubberBand.StartedClamping :		//
										IF iPressureBarClosed AND iJawClampsRetracted THEN
											state := MotorizedPbarStatesRubberBand.Clamping;	
											//Removed this delay and moved the Encoder-Drive Sync to the Motor Control FB.  CT 9/5/23


											//pbarMotor.AllowClamping();
											//delayTimer.PT := T#250MS;
											//delayTimer.IN := TRUE;
											//IF delayTimer.Q THEN
												//pbarMotor.AllowClamping();
											//	pbarMotor.ResetEncoderPosition(pbarMotor.driveInputs[5]);
											//	state := MotorizedPbarStatesRubberBand.Clamping;	


											//END_IF
										END_IF
										
										
										IF testActive THEN
											delayTimer.PT := T#2S;
											delayTimer.IN := TRUE;
										END_IF
	
	
	MotorizedPbarStatesRubberBand.Clamping :				//
										IF _openJaw OR (testActive AND delayTimer.Q) THEN
											_openJaw := FALSE;
											pbarOutCommandedSetting := pbarOutSetting;
											delayTimer.IN := FALSE;
											jawClamps.Extend();
											state := MotorizedPbarStatesRubberBand.ReleaseClamp;
										END_IF
										
										IF _openForBagFeed OR (testActive AND delayTimer.Q) THEN
											_openForBagFeed := FALSE;
											pbarOutCommandedSetting := pbarBagFeedSetting;
											delayTimer.IN := FALSE;
											jawClamps.Extend();
											state := MotorizedPbarStatesRubberBand.ReleaseClamp;
										END_IF
										
	
	
	
	MotorizedPbarStatesRubberBand.ReleaseClamp :			//  
										IF iJawClampExtended THEN
											pbarMotor.DoneClamping();
											//pbarMotor.Enable();
											delayTimer.PT := jawClampsDelay;
											delayTimer.IN := TRUE;
											state := MotorizedPbarStatesRubberBand.ReleasingClamp;
										END_IF
										
	
	
	MotorizedPbarStatesRubberBand.ReleasingClamp :		//
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											state := MotorizedPbarStatesRubberBand.MoveJawOut;
											//HMI.data.TFBeltPressureBarCycles := HMI.data.TFBeltPressureBarCycles + 1;
										END_IF
	
	MotorizedPbarStatesRubberBand.Faulting :			// 
										Globals.jawMovingIn := FALSE;
										_reset := FALSE;
										_openJaw := FALSE;
										_closeJaw := FALSE;
										_homeNow := FALSE;
										_closeJawNoLatch := FALSE;
										_openForBagFeed := FALSE;
										startTest := FALSE;
										testActive := FALSE;
										delayTimer.IN := FALSE;
										jawClamps.Extend();
										pbarFeedbackHandler.extendOutput := FALSE;
										pbarFeedbackHandler.retractOutput := FALSE;
										pbarMotor.Disable();
										//IBDMotor.Disable();
										state := MotorizedPbarStatesRubberBand.Faulted;
			
	MotorizedPbarStatesRubberBand.Faulted :				//
	
END_CASE


IF pbarMotor.alarms.positionLimit OR failTimer.Q THEN
	faults.obstructionDetected.faultTrigger := TRUE;
	//homeRequired := TRUE;
	//state := MotorizedPbarStatesRubberBand.Faulting;
ELSE
	faults.obstructionDetected.faultTrigger := FALSE;
END_IF

pbarFeedbackHandler(
	extendedFeedbackInput:= pressureBarOpen, 
	retractedFeedbackInput:= iPressureBarClosed, 
	extendOutput:= state = MotorizedPbarStatesRubberBand.MovingJawOut, 
	retractOutput:= state = MotorizedPbarStatesRubberBand.MovingJawIn, 
	extendFaultDelay:= 3000 , 
	retractFaultDelay:= 3000 , 
	faultMonitoring:= distanceToMove > 0.5, 
	failedToExtend=> faults.failedToOpen.faultTrigger, 
	failedToRetract=> faults.failedToClose.faultTrigger);
	
SUPER^();
