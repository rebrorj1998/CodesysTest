(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionMotorModbus EXTENDS Axis_REF
VAR_INPUT
	stepsPerInchSP : DINT := 3999;
	zeroOffset : REAL;
	jogForwardCMD : BOOL;
	jogReverseCMD : BOOL;
END_VAR
VAR_OUTPUT
	statusCode : WORD;
	alarmCode : WORD;
END_VAR
VAR
	xFirstScan:BOOL := TRUE;
	waitForHaltTimer : Standard.TON := (PT := T#20MS);
	modbusDwordBuffer: uModbusDWORD;
	status : FB_AppliedMotionStatus;
	alarms : FB_AppliedMotionAlarms;
	state : eAppliedMotionDriveStatesASCII;
	alarmONS : FB_ONS;
	haltONS : FB_ONS;
	freeMotor: BOOL;
	zHome: BOOL;
	reset: BOOL;
END_VAR
VAR CONSTANT
	UNITS_PER_ROTATION:REAL := 4;
	RPS_TO_RPM:REAL := 60;
	REVS_PER_INCH_OF_FEED:REAL := 0.489;
	ACCEL_DECEL_RATE_IN_RPM:WORD := 600;
	SK_OPCODE:WORD :=  225;
	FL_OPCODE:WORD := 102;
	AX_OPCODE:WORD := 186;
	ME_OPCODE:WORD := 159;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_OrientalAZMotor()
//	Description: A PLCOpen Motion compliant library for a Oriental AZ Series drive/motor
//				 
//	Created by: Ben Hess
//	Created Date: Tuesday, June 2nd 2020

// Outputs for Motion Lib
PowerState := PowerOn;
EnableState := DriveEnable;

// Exit if drive isn't enabled.
IF NOT DriveEnable THEN
	RETURN;
END_IF

haltONS(CLK := Halt);
IF haltONS.OSR THEN
	state := eAppliedMotionDriveStatesASCII.Halt;
END_IF
waitForHaltTimer(IN := state = eAppliedMotionDriveStatesASCII.Halting);

// Get drive data directly from master axis	
status(statusCode:= filmFeedDriveInputs[1]);
IF status.moving THEN 
	ActVelocity := ProfileVelocity;
ELSE
	ActVelocity := 0;
END_IF

alarmONS(CLK := status.driveFaulted);
IF alarmONS.OSR THEN
	Error := TRUE;
	state := eAppliedMotionDriveStatesASCII.Faulting;
END_IF

CASE state OF
	eAppliedMotionDriveStatesASCII.Idle:
				// 	Idle state, wait for command
				mClearStatus();
				mSetAccelDecel();
				IF MoveAbs THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStatesASCII.MoveABS;
				ELSIF MoveRel THEN
					filmFeedDriveOutputs[2] := TO_WORD(mVeloAccDecCalc(ProfileVelocity));
					triggerFilmDriveOutputUpdate := TRUE;
					IF filmFeedDriveInputs[29] = filmFeedDriveOutputs[2] THEN
						triggerFilmDriveOutputUpdate := FALSE;
						AxisState := AXIS_STATE.AS_DiscreteMotion;
						state := eAppliedMotionDriveStatesASCII.MoveInc;
					END_IF		
				ELSIF MoveAbsTorque THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStatesASCII.MoveABS;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					filmFeedDriveOutputs[2] := TO_WORD(mVeloAccDecCalc(1));
					triggerFilmDriveOutputUpdate := TRUE;
					IF filmFeedDriveInputs[29] = filmFeedDriveOutputs[2] THEN
						triggerFilmDriveOutputUpdate := FALSE;
						AxisState := AXIS_STATE.AS_DiscreteMotion;
						state := eAppliedMotionDriveStatesASCII.StartJogging;
					END_IF					
				ELSIF StartHoming THEN
					//AxisState := AXIS_STATE.AS_Homing;
					state := eAppliedMotionDriveStatesASCII.Home;
				END_IF

		eAppliedMotionDriveStatesASCII.MoveABS:	
		eAppliedMotionDriveStatesASCII.MoveInc:
				// Move to incremental position
				mSetFeedToLength(mDistanceCalc(TargetPosDist));
				IF filmFeedDriveInputs[31] = filmFeedDriveOutputs[4] THEN
					triggerFilmDriveOutputUpdate := FALSE;
					currentOpcodeOutput := FL_OPCODE;
					triggerFilmDriveOpCode := TRUE;
					IF status.moving THEN
						triggerFilmDriveOpCode := FALSE;
						state := eAppliedMotionDriveStatesASCII.Moving;
					END_IF
				END_IF
		
		eAppliedMotionDriveStatesASCII.Home:
		eAppliedMotionDriveStatesASCII.Homing:		
				//
				IF status.inPosition THEN
					zHome := FALSE;
					HomingDone := TRUE;
					state := eAppliedMotionDriveStatesASCII.DoneMoving;
				END_IF
		
		eAppliedMotionDriveStatesASCII.StartJogging:
				// Begin jog move 
				IF jogForwardCMD THEN
					mSetFeedToLength(mDistanceCalc(30));
					IF filmFeedDriveInputs[31] = filmFeedDriveOutputs[4] THEN
						triggerFilmDriveOutputUpdate := FALSE;
						currentOpcodeOutput := FL_OPCODE;
						triggerFilmDriveOpCode := TRUE;
					END_IF
				ELSIF jogReverseCMD THEN
					mSetFeedToLength(mDistanceCalc(-30));
					IF filmFeedDriveInputs[31] = filmFeedDriveOutputs[4] THEN
						triggerFilmDriveOutputUpdate := FALSE;
						currentOpcodeOutput := FL_OPCODE;
						triggerFilmDriveOpCode := TRUE;
					END_IF
				END_IF
				
				IF status.moving THEN
					triggerFilmDriveOpCode := FALSE;
					state := eAppliedMotionDriveStatesASCII.Jogging;
				END_IF
				
		eAppliedMotionDriveStatesASCII.Jogging:
				// Jog forward/reverse
				IF NOT jogForwardCMD AND NOT jogReverseCMD THEN
					currentOpcodeOutput := SK_OPCODE;
					triggerFilmDriveOpCode := TRUE;
					IF NOT status.moving THEN
						triggerFilmDriveOpCode := FALSE;
						state := eAppliedMotionDriveStatesASCII.Idle;
					END_IF
				END_IF
				
		eAppliedMotionDriveStatesASCII.SendOpcodeAfterPars:
		eAppliedMotionDriveStatesASCII.Moving:
				// After sending data, we are moving
				ActVelocity := ProfileVelocity;
				IF status.inPosition AND NOT status.moving THEN
					TargetReached := TRUE;
					state := eAppliedMotionDriveStatesASCII.DoneMoving;
				END_IF
		
		eAppliedMotionDriveStatesASCII.DoneMoving:
				// Wait for status to clear
				IF NOT MoveAbs AND NOT MoveAbsTorque AND NOT MoveRel AND NOT StartHoming THEN
					AxisState := AXIS_STATE.AS_Standstill;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF 

		eAppliedMotionDriveStatesASCII.Halt:
				//
				currentOpcodeOutput := SK_OPCODE;
				triggerFilmDriveOpCode := TRUE;
				state := eAppliedMotionDriveStatesASCII.HaltSending;
				
		eAppliedMotionDriveStatesASCII.HaltSending:
				//
				IF NOT status.moving THEN
					triggerFilmDriveOpCode := FALSE;
					state := eAppliedMotionDriveStatesASCII.Halting;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Halting:
				//		
				IF waitForHaltTimer.Q THEN
					ActVelocity := 0;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Faulting:
				// Faulting - stop drive
				mClearStatus();
				AxisState := AXIS_STATE.AS_ErrorStop;
				Error := TRUE;
				freeMotor := TRUE;
				currentOpcodeOutput := SK_OPCODE;
				triggerFilmDriveOpCode := TRUE;
				IF NOT status.moving THEN
					triggerFilmDriveOpCode := FALSE;
					state := eAppliedMotionDriveStatesASCII.FaultGetAlarmCode;
				END_IF
		
		eAppliedMotionDriveStatesASCII.FaultGetAlarmCode:
				// Get alarm code and display
				alarms(alarmCode:= filmFeedDriveInputs[0]);
				state := eAppliedMotionDriveStatesASCII.EnableMotor;
		
		eAppliedMotionDriveStatesASCII.Faulted:
				// Faulted - wait for clear
				IF AckError THEN
					IF status.driveFaulted THEN
						currentOpcodeOutput := AX_OPCODE;
						triggerFilmDriveOpCode := TRUE;
						IF alarms.alarmCode = 0 THEN
							triggerFilmDriveOpCode := FALSE;
							state := eAppliedMotionDriveStatesASCII.EnableMotor;
						END_IF
					ELSE
						state := eAppliedMotionDriveStatesASCII.Idle;
					END_IF
				END_IF
				
		eAppliedMotionDriveStatesASCII.EnableMotor:
				//
				currentOpcodeOutput := ME_OPCODE;
				triggerFilmDriveOpCode := TRUE;
				IF status.motorEnabled THEN
					triggerFilmDriveOpCode := FALSE;
					Error := FALSE;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF
END_CASE
alarmCode := alarms.alarmCode;
statusCode := status.statusCode;
