(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_OrientalAZMotor EXTENDS Sharp_Motion.Axis_REF
VAR_INPUT
	modbusAddress : USINT;
	isGroup : BOOL;
	stepsPerInchSP : DINT := 3999;
	zeroOffset : REAL;
	jogForwardCMD : BOOL;
	jogReverseCMD : BOOL;
	groupMotor0 : REFERENCE TO FB_OrientalAZMotor; // Master Motor
	groupMotor1 : REFERENCE TO FB_OrientalAZMotor;	// Slave Motor
END_VAR
VAR_OUTPUT
	triggerDDWriteNow : BOOL;
	triggerRIOWriteNow : BOOL;
END_VAR
VAR
	directDataOp : sctOrientalDirectData;
	distanceFromDrive : uModbusDWORD;
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
	zHomeDelay : Standard.TON := (PT := T#3500MS);
	modbusWriteResponse : ARRAY[0..20] OF WORD;
	readData : IoDrvModbus.ModbusChannel;
	readDataAfterWrite : IoDrvModbus.ModbusChannel;
	//readDataMBCommand : IoDrvModbus.ModbusCommand;
	writeDirectOpData : IoDrvModbus.ModbusChannel;
  	//writeDirectOpDataMBCommand : IoDrvModbus.ModbusCommand;
	writeRIOData : IoDrvModbus.ModbusChannel;
  	//writeRIODataMBCommand : IoDrvModbus.ModbusCommand;
   	readRateTimer : Standard.TON := (PT:= T#200MS);
	readAfterDDWrite : FB_ONS;
	readAfterRIOWrite : FB_ONS;
	haltONS : FB_ONS;
	alarmActiveONS : FB_ONS;
	triggerRIOWrite : BOOL;
	
	disable : BOOL;
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
	RETURN;
END_IF

// Pack data for direct data operation
modbusDirectDataToDrive[0] := directDataOp.OperationNo.wWord[1];
modbusDirectDataToDrive[1] := directDataOp.OperationNo.wWord[0];
modbusDirectDataToDrive[2] := directDataOp.OperationType.wWord[1];
modbusDirectDataToDrive[3] := directDataOp.OperationType.wWord[0];
modbusDirectDataToDrive[4] := directDataOp.Position.wWord[1];
modbusDirectDataToDrive[5] := directDataOp.Position.wWord[0];
modbusDirectDataToDrive[6] := directDataOp.Speed.wWord[1];
modbusDirectDataToDrive[7] := directDataOp.Speed.wWord[0];
modbusDirectDataToDrive[8] := directDataOp.RateOfChange.wWord[1];
modbusDirectDataToDrive[9] := directDataOp.RateOfChange.wWord[0];
modbusDirectDataToDrive[10] := directDataOp.StoppingDecel.wWord[1];
modbusDirectDataToDrive[11] := directDataOp.StoppingDecel.wWord[0];
modbusDirectDataToDrive[12] := directDataOp.Current.wWord[1];
modbusDirectDataToDrive[13] := directDataOp.Current.wWord[0];
modbusDirectDataToDrive[14] := directDataOp.Trigger.wWord[1];
modbusDirectDataToDrive[15] := directDataOp.Trigger.wWord[0];

// Get raw drive position
IF isGroup THEN
	IF __ISVALIDREF(groupMotor0) THEN
		ActPos := groupMotor0.ActPos;
	END_IF
ELSE
	distanceFromDrive.wWord[0] := modbusDataFromDrive[3];
	distanceFromDrive.wWord[1] := modbusDataFromDrive[2];
	ActPos := (TO_REAL(distanceFromDrive.diDint) / TO_REAL(stepsPerInchSP)) + zeroOffset;
END_IF

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


//IF NOT isGroup THEN
	writeRIOData(
	slave:= MBChannel, 
	xExecute:= , 
	xAbort:= , 
	iChannelIndex:= 2, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );

	writeDirectOpData(
	slave:= MBChannel, 
	xExecute:= , 
	xAbort:= , 
	iChannelIndex:= 1, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );
//END_IF

	
// Read registers from drive
// On a cyclic basis	
readRateTimer(IN := NOT readRateTimer.Q AND NOT (writeRIOData.xBusy OR writeDirectOpData.xBusy OR readData.xBusy OR readDataAfterWrite.xBusy) AND NOT isGroup);
// And directly after a DD op write
readAfterDDWrite(CLK := writeDirectOpData.xDone);
readAfterRIOWrite(CLK := writeRIOData.xDone);

readData(
	slave:= MBChannel, 
	xExecute:= ,//readRateTimer.Q OR readData.xBusy, 
	xAbort:= , 
	iChannelIndex:= 0, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );

IF packedRIO.dDword <> packedRIOLast 
	OR readData.xDone AND modbusDataFromDrive[21] <> packedRIO.dDword
	THEN
	packedRIOLast := packedRIO.dDword;
	writeRIOData.xExecute := TRUE;
END_IF
IF writeRIOData.xDone OR writeRIOData.xError THEN
		writeRIOData.xExecute := FALSE;
END_IF
	
readDataAfterWrite(
	slave:= MBChannel, 
	xExecute:= readAfterDDWrite.OSR OR readDataAfterWrite.xBusy,//(writeDirectOpData.xDone OR writeRIOData.xDone) AND NOT isGroup, 
	xAbort:= , 
	iChannelIndex:= 0, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );

IF NOT isGroup THEN
	IF readData.xError
		OR readDataAfterWrite.xError
		OR writeDirectOpData.xError
		OR writeRIOData.xError 
		OR MBChannel.xError
	THEN
		state := eOrientalAZDriveStates.Faulting;
		CommStatus := FALSE;
	END_IF
END_IF	

(*
writeRIODataMBCommand.uiFunctionCode := 16;
writeRIODataMBCommand.uiwriteLen := 2;
writeRIODataMBCommand.uiwriteOffset := 124;
writeRIOData(
	xExecute:= , 
	xAbort:= , 
	hComPort:= comm, 
	usiSlaveAddr:= modbusAddress, 
	modbusCommand:= writeRIODataMBCommand, 
	tResponseTimeout:= , 
	uiSendTimeout:= , 
	pSendData:= ADR(modbusRIODataToDrive), 
	pRecvData:= ADR(modbusWriteResponse), 
	transmission:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	xAborted=> , 
	uiDataLength=> , 
	byModbusError=> );

writeDirectOpDataMBCommand.uiFunctionCode := 16;
writeDirectOpDataMBCommand.uiwriteLen := 17;
writeDirectOpDataMBCommand.uiwriteOffset := 88;
writeDirectOpData(
	xExecute:= , 
	xAbort:= , 
	hComPort:= comm, 
	usiSlaveAddr:= modbusAddress, 
	modbusCommand:= writeDirectOpDataMBCommand, 
	tResponseTimeout:= , 
	uiSendTimeout:= , 
	pSendData:= ADR(modbusDirectDataToDrive), 
	pRecvData:= ADR(modbusWriteResponse), 
	transmission:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	xAborted=> , 
	uiDataLength=> , 
	byModbusError=> );

// Read registers from drive
// On a cyclic basis
readRateTimer(IN := NOT readRateTimer.Q AND NOT (writeRIOData.xBusy OR writeDirectOpData.xBusy) AND NOT isGroup);
// And directly after a DD op write
readAfterDDWrite(CLK := writeDirectOpData.xDone);
readAfterRIOWrite(CLK := writeRIOData.xDone);

readDataMBCommand.uiFunctionCode := 3;
readDataMBCommand.uiReadLen := 40;
readDataMBCommand.uiReadOffset := 16#1340;
readData(
	xExecute:= readRateTimer.Q OR readAfterDDWrite.OSR OR readAfterRIOWrite.OSR, 
	xAbort:= , 
	hComPort:= comm, 
	usiSlaveAddr:= 15, 
	modbusCommand:= readDataMBCommand, 
	tResponseTimeout:= , 
	uiSendTimeout:= , 
	pSendData:= , 
	pRecvData:= ADR(modbusDataFromDrive), 
	transmission:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	xAborted=> , 
	uiDataLength=> , 
	byModbusError=> );
*)


// Get drive data directly from modbus or from master axis	
IF isGroup THEN
	IF __ISVALIDREF(groupMotor0) AND __ISVALIDREF(groupMotor1) THEN
		ready := groupMotor0.ready AND groupMotor1.ready;
		alarmActive := groupMotor0.alarmActive OR groupMotor1.alarmActive;
		moving := groupMotor0.moving AND groupMotor1.moving;
		inPosition := groupMotor0.inPosition AND groupMotor1.inPosition;
		atTorqueLimit := groupMotor0.atTorqueLimit AND groupMotor1.atTorqueLimit;
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
	state := eOrientalAZDriveStates.Halt;
END_IF

alarmActiveONS(clk:= alarmActive);
IF alarmActiveONS.OSR THEN
	state := eOrientalAZDriveStates.Faulting;
END_IF


CASE state OF
	eOrientalAZDriveStates.Idle:
				// 	Idle state, wait for command
				mClearStatus();
				IF MoveAbs THEN
					AxisState := Sharp_Motion.AXIS_STATE.AS_DiscreteMotion;
					state := eOrientalAZDriveStates.MoveABS;
				ELSIF MoveRel THEN
					AxisState := Sharp_Motion.AXIS_STATE.AS_DiscreteMotion;
					state := eOrientalAZDriveStates.MoveInc;
				ELSIF MoveAbsTorque THEN
					AxisState := Sharp_Motion.AXIS_STATE.AS_DiscreteMotion;
					state := eOrientalAZDriveStates.MovePush;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					state := eOrientalAZDriveStates.Jogging;
				ELSIF StartHoming THEN
					HomingDone := FALSE;
					//AxisState := Sharp_Motion.AXIS_STATE.AS_Homing;
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
				writeDirectOpData.xExecute := TRUE;
				IF isGroup THEN
					state := eOrientalAZDriveStates.DelayAfterWrite;
					nextState := eOrientalAZDriveStates.Moving;
 				ELSE 
					IF writeDirectOpData.xDone AND readDataAfterWrite.xDone THEN
						writeDirectOpData.xExecute := FALSE;
						state := eOrientalAZDriveStates.Moving;
					ELSIF writeDirectOpData.xError OR readDataAfterWrite.xError  THEN
						writeDirectOpData.xExecute := FALSE;
						state := eOrientalAZDriveStates.Faulting;
					END_IF
				END_IF
				
		
	eOrientalAZDriveStates.MovePush:
				// Move to absolute position
				
				directDataOp.OperationType.diDint := eOrientalOperationType.Absolute_Push;
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed.diDint := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.RateOfChange.diDint := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.StoppingDecel.diDint := mVeloAccDecCalc(ProfileDeceleration);
				directDataOp.Current.diDint := mCurrentCalc(ProfileCurrentLimit);
				directDataOp.Trigger.diDint := 1;
				writeDirectOpData.xExecute := TRUE;
				IF isGroup THEN
					state := eOrientalAZDriveStates.DelayAfterWrite;
					nextState := eOrientalAZDriveStates.Moving;
				ELSE 
					IF writeDirectOpData.xDone AND readDataAfterWrite.xDone THEN
						writeDirectOpData.xExecute := FALSE;
						state := eOrientalAZDriveStates.Moving;
					ELSIF writeDirectOpData.xError OR readDataAfterWrite.xError  THEN
						writeDirectOpData.xExecute := FALSE;
						state := eOrientalAZDriveStates.Faulting;
					END_IF
				END_IF
				
		eOrientalAZDriveStates.MoveInc:
				// Move to absolute position
				
				directDataOp.OperationType.diDint := eOrientalOperationType.Incremental_Positioning;
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed.diDint := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.RateOfChange.diDint := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.StoppingDecel.diDint := mVeloAccDecCalc(ProfileDeceleration);
				directDataOp.Current.diDint := mCurrentCalc(DefaultCurrent);
				directDataOp.Trigger.diDint := 1;
				writeDirectOpData.xExecute := TRUE;
				IF isGroup THEN
					state := eOrientalAZDriveStates.DelayAfterWrite;
					nextState := eOrientalAZDriveStates.Moving;
				ELSE 
					IF writeDirectOpData.xDone AND readDataAfterWrite.xDone THEN
						writeDirectOpData.xExecute := FALSE;
						state := eOrientalAZDriveStates.Moving;
					ELSIF writeDirectOpData.xError OR readDataAfterWrite.xError  THEN
						writeDirectOpData.xExecute := FALSE;
						state := eOrientalAZDriveStates.Faulting;
					END_IF
				END_IF
		
		eOrientalAZDriveStates.Home:
				//
				zHome := TRUE;
				IF isGroup THEN
					state := eOrientalAZDriveStates.DelayAfterWrite;
					nextState := eOrientalAZDriveStates.Homing;
				ELSE 
					IF writeRIOData.xDone THEN
						state := eOrientalAZDriveStates.Homing;
					ELSIF writeRIOData.xError THEN
						state := eOrientalAZDriveStates.Faulting;
					END_IF
				END_IF
				
				
		
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
					writeDirectOpData.xExecute := FALSE;
					writeRIOData.xExecute := FALSE;
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
					AxisState := Sharp_Motion.AXIS_STATE.AS_Standstill;
					state := eOrientalAZDriveStates.Idle;
				END_IF 

		eOrientalAZDriveStates.Halt:
				// 
				freeMotor := TRUE;
				state := eOrientalAZDriveStates.Idle;
				
		eOrientalAZDriveStates.Faulting:
				// Faulting - stop drive
				mClearStatus();
				AxisState := Sharp_Motion.AXIS_STATE.AS_ErrorStop;
				Error := TRUE;
				freeMotor := TRUE;
				state := eOrientalAZDriveStates.Faulted;
				
		eOrientalAZDriveStates.Faulted:
				// Faulted - wait for clear
				IF AckError THEN
					CommStatus := TRUE;
					IF alarmActive THEN
						reset := TRUE;
					END_IF
					IF NOT alarmActive THEN
						reset := FALSE;
						state := eOrientalAZDriveStates.Idle;
					END_IF
					
				END_IF
END_CASE
triggerDDWriteNow := writeDirectOpData.xExecute;
triggerRIOWriteNow := writeRIOData.xExecute;