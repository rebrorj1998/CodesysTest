(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_OrientalAZMotorTrigger EXTENDS Axis_REF
VAR_INPUT
	isGroup : BOOL;
	stepsPerInchSP : DINT := 3999;
	zeroOffset : REAL;
	jogForwardCMD : BOOL;
	jogReverseCMD : BOOL;
	groupMotor0 : REFERENCE TO FB_OrientalAZMotorTrigger; // Master Motor
	groupMotor1 : REFERENCE TO FB_OrientalAZMotorTrigger;	// Slave Motor
END_VAR
VAR_OUTPUT
	alarmCode : DWORD;
	triggerDDWriteNow : BOOL;
	triggerRIOWriteNow : BOOL;
END_VAR
VAR
	directDataOp : sctOrientalDirectData;
	distanceFromDrive : uModbusDWORD;
	alarmCodeFromDrive : uModbusDWORD;
	ready : BOOL;
	alarmActive : BOOL;
	moving : BOOL;
	inPosition : BOOL;
	atTorqueLimit : BOOL;
	atPosition : BOOL;
	homeSwitchTrigger : BOOL;
	homeNow : BOOL;
	P_Preset : BOOL;
	start : BOOL;
	zHome : BOOL;
	stop : BOOL;
	freeMotor : BOOL;
	reset : BOOL;
	EL_Preset : BOOL;
	jogReverse : BOOL;
	jogForward : BOOL;
	packedRIO : uModbusDWORD;
	packedRIOLast : DWORD;
	delayTimer : Standard.TON := (PT := T#250MS);
	zHomeDelay : Standard.TON := (PT := T#2000MS);
	modbusWriteResponse : ARRAY[0..20] OF WORD;
	readAfterDDWrite : FB_ONS;
	readAfterRIOWrite : FB_ONS;
	haltONS : FB_ONS;
	alarmActiveONS : FB_ONS;
	triggerRIOWrite : BOOL;
	resetRIOWrite : Standard.TON := (PT := T#50MS);
	disable : BOOL;
	enumAlarmCode : eOrientalAZDriveFaults;
	state : eOrientalAZDriveStates;
	nextState : eOrientalAZDriveStates;
	
END_VAR
VAR_IN_OUT
	MBChannel : IoDrvModbus.ModbusSlaveComPort;
	modbusDataFromDrive : ARRAY[0..39] OF WORD;
	modbusDirectDataToDrive : ARRAY[0..16] OF WORD;
	modbusRIODataToDrive : ARRAY[0..1] OF WORD;
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



// Get raw drive position and alarm code
IF isGroup THEN
	IF __ISVALIDREF(groupMotor0) THEN
		ActPos := groupMotor0.ActPos;
		enumAlarmCode := groupMotor0.enumAlarmCode;
	END_IF
ELSE
	distanceFromDrive.wWord[0] := modbusDataFromDrive[3];
	distanceFromDrive.wWord[1] := modbusDataFromDrive[2];
	ActPos := (TO_REAL(distanceFromDrive.diDint) / TO_REAL(stepsPerInchSP)) + zeroOffset;
	alarmCodeFromDrive.wWord[0] := modbusDataFromDrive[7];
	alarmCodeFromDrive.wWord[1] := modbusDataFromDrive[6];
	enumAlarmCode := TO_INT(alarmCodeFromDrive.diDint);
END_IF
alarmCode := enumAlarmCode;

// Pack RIO to write to drive
packedRIO.dDword.0 := homeSwitchTrigger;
packedRIO.dDword.1 := homeNow;
packedRIO.dDword.2 := P_Preset;
packedRIO.dDword.3 := start;
packedRIO.dDword.4 := zHome;
packedRIO.dDword.5 := stop;
packedRIO.dDword.6 := freeMotor;
packedRIO.dDword.7 := reset;
packedRIO.dDword.12 := EL_Preset;
packedRIO.dDword.13 := jogReverse;
packedRIO.dDword.14 := jogForward;
modbusRIODataToDrive[0] := packedRIO.wWord[1];
modbusRIODataToDrive[1] := packedRIO.wWord[0];

delayTimer(IN := state = eOrientalAZDriveStates.DelayAfterWrite);
zHomeDelay(IN := state = eOrientalAZDriveStates.Homing);
// Trigger an RIO write whenever it changes


IF packedRIO.dDword <> packedRIOLast THEN
	packedRIOLast := packedRIO.dDword;
	triggerRIOWriteNow := TRUE;
END_IF
resetRIOWrite(IN := triggerRIOWriteNow);
IF resetRIOWrite.Q THEN
	triggerRIOWriteNow := FALSE;
END_IF


IF NOT isGroup THEN
	IF MBChannel.xError THEN
		state := eOrientalAZDriveStates.Faulting;
		CommStatus := FALSE;
	END_IF
END_IF	


// Get drive data directly from modbus or from master axis	
IF isGroup THEN
	IF __ISVALIDREF(groupMotor0) AND __ISVALIDREF(groupMotor1) THEN
		ready := groupMotor0.ready AND groupMotor1.ready;
		alarmActive := groupMotor0.alarmActive OR groupMotor1.alarmActive;
		moving := groupMotor0.moving AND groupMotor1.moving;
		inPosition := groupMotor0.inPosition AND groupMotor1.inPosition;
		atTorqueLimit := groupMotor0.atTorqueLimit OR groupMotor1.atTorqueLimit;
	END_IF
ELSE
	Ready := modbusDataFromDrive[5].5;
	AlarmActive := modbusDataFromDrive[5].7;
	Moving := modbusDataFromDrive[5].13;
	InPosition := modbusDataFromDrive[5].14;
	AtTorqueLimit := modbusDataFromDrive[5].15;
END_IF

haltONS(CLK := Halt);
IF haltONS.OSR THEN
	state := eOrientalAZDriveStates.Faulting;
END_IF

IF AckError THEN
	state := eOrientalAZDriveStates.Resetting;
END_IF
alarmActiveONS(clk:= alarmActive);
IF alarmActiveONS.OSR THEN
	state := eOrientalAZDriveStates.Faulting;
END_IF


CASE state OF
	eOrientalAZDriveStates.Idle:
				// 	Idle state, wait for command
				//mClearStatus();
				
				IF MoveAbs THEN
					TargetReached := FALSE;
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eOrientalAZDriveStates.MoveABS;
				ELSIF MoveRel THEN
					TargetReached := FALSE;
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eOrientalAZDriveStates.MoveInc;
				ELSIF MoveAbsTorque THEN
					TargetReached := FALSE;
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eOrientalAZDriveStates.MovePush;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					state := eOrientalAZDriveStates.Jogging;
				ELSIF StartHoming THEN
					HomingDone := FALSE;
					//AxisState := AXIS_STATE.AS_Homing;
					state := eOrientalAZDriveStates.Home;
				END_IF
				IF MBChannel.xDone OR isGroup THEN
					CommStatus := TRUE;
				END_IF

	eOrientalAZDriveStates.MoveABS:
				// Move to absolute position
				
				directDataOp.OperationType.diDint := eOrientalOperationType.Absolute_Positioning;
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed.diDint := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.RateOfChange.diDint := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.StoppingDecel.diDint := mVeloAccDecCalc(ProfileDeceleration);
				directDataOp.Current.diDint := mCurrentCalc(DefaultCurrent);
				directDataOp.Trigger.diDint := 1;
				mPackDDOp();
				triggerDDWriteNow := TRUE;
				state := eOrientalAZDriveStates.DelayAfterWrite;
				nextState := eOrientalAZDriveStates.Moving;
				
				
		
	eOrientalAZDriveStates.MovePush:
				// Move to absolute position
				
				directDataOp.OperationType.diDint := eOrientalOperationType.Absolute_Push;
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed.diDint := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.RateOfChange.diDint := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.StoppingDecel.diDint := mVeloAccDecCalc(ProfileDeceleration);
				directDataOp.Current.diDint := mCurrentCalc(ProfileCurrentLimit);
				directDataOp.Trigger.diDint := 1;
				mPackDDOp();
				triggerDDWriteNow := TRUE;
				
				
				state := eOrientalAZDriveStates.DelayAfterWrite;
				nextState := eOrientalAZDriveStates.Moving;
				
				
		eOrientalAZDriveStates.MoveInc:
				// Move to absolute position
				
				directDataOp.OperationType.diDint := eOrientalOperationType.Incremental_Positioning;
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed.diDint := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.RateOfChange.diDint := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.StoppingDecel.diDint := mVeloAccDecCalc(ProfileDeceleration);
				directDataOp.Current.diDint := mCurrentCalc(DefaultCurrent);
				directDataOp.Trigger.diDint := 1;
				mPackDDOp();
				triggerDDWriteNow := TRUE;
				
				state := eOrientalAZDriveStates.DelayAfterWrite;
				nextState := eOrientalAZDriveStates.Moving;
				
		eOrientalAZDriveStates.Home:
				//
				zHome := TRUE;
				
				state := eOrientalAZDriveStates.DelayAfterWrite;
				nextState := eOrientalAZDriveStates.Homing;
				
		
		eOrientalAZDriveStates.Homing:		
				//
				IF inPosition AND zHomeDelay.Q THEN
					zHome := FALSE;
					HomingDone := TRUE;
					state := eOrientalAZDriveStates.DoneMoving;
				END_IF
				
		eOrientalAZDriveStates.Jogging:
				// Jog forward/reverse
				jogForward := jogForwardCMD;
				jogReverse := jogReverseCMD;
				
				IF NOT jogForward AND NOT jogReverse THEN
					state := eOrientalAZDriveStates.Idle;
				END_IF
		
		eOrientalAZDriveStates.DelayAfterWrite:
				//
				IF delayTimer.Q THEN
					triggerDDWriteNow := FALSE;
					state := nextState;
				END_IF
		
		eOrientalAZDriveStates.Moving:
				// After sending data, we are moving
				IF inPosition OR (atTorqueLimit AND MoveAbsTorque) THEN
					TargetReached := TRUE;
					state := eOrientalAZDriveStates.DoneMoving;
				END_IF
		
		eOrientalAZDriveStates.DoneMoving:
				// Wait for status to clear
				IF NOT MoveAbs AND NOT MoveAbsTorque AND NOT MoveRel AND NOT StartHoming THEN
					AxisState := AXIS_STATE.AS_Standstill;
					state := eOrientalAZDriveStates.Idle;
				END_IF 

		eOrientalAZDriveStates.Halt:
				// 
				freeMotor := TRUE;
				state := eOrientalAZDriveStates.Idle;
				
		eOrientalAZDriveStates.Halted:
				// 
				freeMotor := TRUE;
				state := eOrientalAZDriveStates.Idle;
				
		eOrientalAZDriveStates.Faulting:
				// Faulting - stop drive
				mClearStatus();
				AxisState := AXIS_STATE.AS_ErrorStop;
				Error := TRUE;
				freeMotor := TRUE;
				zHome := FALSE;
				triggerRIOWriteNow := TRUE;
				state := eOrientalAZDriveStates.Faulted;
				
		eOrientalAZDriveStates.Faulted:
				// Faulted - wait for clear
				IF AckError THEN
					state := eOrientalAZDriveStates.Resetting;
				END_IF
		
		eOrientalAZDriveStates.Resetting:
				// 
					CommStatus := TRUE;
					IF alarmActive THEN
						reset := TRUE;
					END_IF
					IF NOT alarmActive THEN
						triggerDDWriteNow := FALSE;
						triggerRIOWriteNow := FALSE;
						AckError := FALSE;
						Error := FALSE;
						freeMotor := FALSE;
						reset := FALSE;
						zHome := FALSE;
						MoveAbs := FALSE;
						MoveRel := FALSE;
						MoveAbsTorque := FALSE;
						StartHoming := FALSE;
						state := eOrientalAZDriveStates.Idle;
					END_IF
					
					
					
END_CASE

