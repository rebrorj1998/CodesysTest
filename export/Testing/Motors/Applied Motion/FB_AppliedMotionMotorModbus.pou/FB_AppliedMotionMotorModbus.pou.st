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
	modbusRIODataTrigger:BOOL;
	modbusOPCodeTrigger:BOOL;
END_VAR
VAR
	xFirstScan:BOOL := TRUE;
	waitForHaltTimer : Standard.TON := (PT := T#20MS);
	modbusDwordBuffer : uModbusDWORD;
	status : FB_AppliedMotionStatus;
	alarms : FB_AppliedMotionAlarms;
	state : eAppliedMotionDriveStatesASCII;
	commErrorONS : FB_ONS;
	commErrorFaultONS : FB_ONS;
	commErrorCount : DINT;
	commErrorFaultSetting : DINT := 3;
	alarmONS : FB_ONS;
	haltONS : FB_ONS;
	freeMotor: BOOL;
	zHome: BOOL;
	reset: BOOL;
END_VAR
VAR_IN_OUT
	MBChannel:IoDrvModbus.ModbusSlaveComPort;
	modbusDataFromDrive:ARRAY[0..31] OF WORD;
	modbusRIODataToDrive:ARRAY[0..4] OF WORD;
	modbusOPCodeToDrive:WORD;
END_VAR
VAR CONSTANT
	UNITS_PER_ROTATION:REAL := 4; // 1 unit = .25 RPM
	RPS_TO_RPM:REAL := 60; // Convert Revolution Per Seconds to Revolution Per Minute
	REVS_PER_INCH_OF_FEED:REAL := 0.489;
	ACCEL_DECEL_RATE_IN_RPM:WORD := 600; // 1 unit = 10 RPM/S, 600 equals 100 RPS/S which is the default Accel/Decel in SCL
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
	Error := FALSE;
	RETURN;
END_IF

// Only set comm error status after x modbus errors
commErrorONS(CLK := MBChannel.xError);
IF commErrorONS.OSR THEN
	commErrorCount := commErrorCount + 1;
END_IF
commErrorFaultONS(CLK := commErrorCount = commErrorFaultSetting);
IF commErrorFaultONS.OSR THEN
	state := eAppliedMotionDriveStatesASCII.Faulting;
	CommStatus := FALSE;
END_IF

haltONS(CLK := Halt);
IF haltONS.OSR THEN
	state := eAppliedMotionDriveStatesASCII.Halt;
END_IF
waitForHaltTimer(IN := state = eAppliedMotionDriveStatesASCII.Halting);

alarms(alarmCode:= modbusDataFromDrive[0]);	
// Get drive data directly from master axis
status(statusCode:= modbusDataFromDrive[1]);
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
					modbusRIODataToDrive[2] := TO_WORD(mVeloAccDecCalc(ProfileVelocity));
					modbusRIODataTrigger := TRUE;
					IF modbusDataFromDrive[29] = modbusRIODataToDrive[2] THEN
						modbusRIODataTrigger := FALSE;
						AxisState := AXIS_STATE.AS_DiscreteMotion;
						state := eAppliedMotionDriveStatesASCII.MoveInc;
					END_IF		
				ELSIF MoveAbsTorque THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStatesASCII.MoveABS;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					modbusRIODataToDrive[2] := TO_WORD(mVeloAccDecCalc(1));
					modbusRIODataTrigger := TRUE;
					IF modbusDataFromDrive[29] = modbusRIODataToDrive[2] THEN
						modbusRIODataTrigger := FALSE;
						AxisState := AXIS_STATE.AS_DiscreteMotion;
						state := eAppliedMotionDriveStatesASCII.StartJogging;
					END_IF					
				ELSIF StartHoming THEN
					//AxisState := AXIS_STATE.AS_Homing;
					state := eAppliedMotionDriveStatesASCII.Home;
				END_IF
				IF MBChannel.xDone THEN
					commStatus := TRUE;
					commErrorCount := 0;
				END_IF

		eAppliedMotionDriveStatesASCII.MoveABS:	
		eAppliedMotionDriveStatesASCII.MoveInc:
				// Move to incremental position
				mSetFeedToLength(mDistanceCalc(TargetPosDist));
				IF modbusDataFromDrive[31] = modbusRIODataToDrive[4] THEN
					modbusRIODataTrigger := FALSE;
					modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.FEED_TO_LENGTH);
					modbusOPCodeTrigger := TRUE;
					IF status.moving THEN
						modbusOPCodeTrigger := FALSE;
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
					IF modbusDataFromDrive[31] = modbusRIODataToDrive[4] THEN
						modbusRIODataTrigger := FALSE;
						modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.FEED_TO_LENGTH);
						modbusOPCodeTrigger := TRUE;
					END_IF
				ELSIF jogReverseCMD THEN
					mSetFeedToLength(mDistanceCalc(-30));
					IF modbusDataFromDrive[31] = modbusRIODataToDrive[4] THEN
						modbusRIODataTrigger := FALSE;
						modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.FEED_TO_LENGTH);
						modbusOPCodeTrigger := TRUE;
					END_IF
				END_IF
				
				IF status.moving THEN
					modbusOPCodeTrigger := FALSE;
					state := eAppliedMotionDriveStatesASCII.Jogging;
				END_IF
				
		eAppliedMotionDriveStatesASCII.Jogging:
				// Jog forward/reverse
				IF NOT jogForwardCMD AND NOT jogReverseCMD THEN
					modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.STOP_MOVE_KILL_BUFFER);
					modbusOPCodeTrigger := TRUE;
					IF NOT status.moving THEN
						modbusOPCodeTrigger := FALSE;
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
				modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.STOP_MOVE_KILL_BUFFER);
				modbusOPCodeTrigger := TRUE;
				state := eAppliedMotionDriveStatesASCII.HaltSending;
				
		eAppliedMotionDriveStatesASCII.HaltSending:
				//
				IF NOT status.moving THEN
					modbusOPCodeTrigger := FALSE;
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
				IF Error THEN
					mClearStatus();
					Error := TRUE;
				ELSE
					mClearStatus();
				END_IF
				
				AxisState := AXIS_STATE.AS_ErrorStop;
				freeMotor := TRUE;
				modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.STOP_MOVE_KILL_BUFFER);
				modbusOPCodeTrigger := TRUE;
				IF NOT status.moving THEN
					modbusOPCodeTrigger := FALSE;
					state := eAppliedMotionDriveStatesASCII.Faulted;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Faulted:
				// Faulted - wait for clear
				IF status.driveFaulted THEN
					modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.ALARM_OUTPUT);
					modbusOPCodeTrigger := TRUE;
					IF alarms.alarmCode = 0 THEN
						modbusOPCodeTrigger := FALSE;
						IF AckError THEN
							state := eAppliedMotionDriveStatesASCII.EnableMotor;
						END_IF
					END_IF
				ELSE
					IF AckError THEN
						Error := FALSE;
						CommStatus := TRUE;
						commErrorCount := 0;
						state := eAppliedMotionDriveStatesASCII.Idle;
					END_IF
				END_IF
				
		eAppliedMotionDriveStatesASCII.EnableMotor:
				//
				modbusOPCodeToDrive := TO_WORD(eAppliedMotionOpcodes.MOTOR_ENABLE);
				modbusOPCodeTrigger := TRUE;
				IF status.motorEnabled THEN
					modbusOPCodeTrigger := FALSE;
					Error := FALSE;
					CommStatus := TRUE;
					commErrorCount := 0;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF
END_CASE
alarmCode := alarms.alarmCode;
statusCode := status.statusCode;
