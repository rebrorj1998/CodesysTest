(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_OrientalAZMotor EXTENDS Sharp_Motion.Axis_REF
VAR_INPUT
	modbusAddress : USINT;
	stepsPerInchSP : DINT;
	zeroOffset : REAL;
	jogForwardCMD : BOOL;
	jogReverseCMD : BOOL;
END_VAR
VAR_OUTPUT
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
	modbusDataFromDrive : ARRAY[0..39] OF WORD;
	modbusDirectDataToDrive : ARRAY[0..16] OF WORD;
	modbusRIODataToDrive : ARRAY[0..1] OF WORD;
	modbusWriteResponse : ARRAY[0..20] OF WORD;
	readData : IoDrvModbus.ModbusRequest2;
	readDataMBCommand : IoDrvModbus.ModbusCommand;
	writeDirectOpData : IoDrvModbus.ModbusRequest2;
  	writeDirectOpDataMBCommand : IoDrvModbus.ModbusCommand;
	writeRIOData : IoDrvModbus.ModbusRequest2;
  	writeRIODataMBCommand : IoDrvModbus.ModbusCommand;
   	readRateTimer : Standard.TON := (PT:= T#20MS);
	readAfterDDWrite : FB_ONS;
	readAfterRIOWrite : FB_ONS;
	triggerRIOWrite : BOOL;
	(*Temp for testing*)
	triggerNow : BOOL;
	disable : BOOL;
	state : eOrientalAZDriveStates;
END_VAR
VAR_IN_OUT
	comm : IoDrvModbus.RTS_IEC_HANDLE;
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
distanceFromDrive.wWord[0] := modbusDataFromDrive[1];
distanceFromDrive.wWord[1] := modbusDataFromDrive[0];
ActPos := (TO_REAL(distanceFromDrive.diDint) / TO_REAL(stepsPerInchSP)) + zeroOffset;
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

// Trigger an RIO write whenever it changes

IF packedRIO.dDword <> packedRIOLast 
	OR readData.xDone AND modbusDataFromDrive[21] <> packedRIO.dDword
	THEN
	packedRIOLast := packedRIO.dDword;
	writeRIOData.xExecute := TRUE;
END_IF

IF writeRIOData.xDone OR writeRIOData.xError THEN
		writeRIOData.xExecute := FALSE;
END_IF

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
readRateTimer(IN := NOT readRateTimer.Q AND NOT (writeRIOData.xBusy OR writeDirectOpData.xBusy));
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

Ready := modbusDataFromDrive[5].5;
AlarmActive := modbusDataFromDrive[5].7;
Moving := modbusDataFromDrive[5].13;
InPosition := modbusDataFromDrive[5].14;
AtTorqueLimit := modbusDataFromDrive[5].15;

IF alarmActive THEN
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
					state := eOrientalAZDriveStates.MoveInc;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					state := eOrientalAZDriveStates.Jogging;
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
				IF writeDirectOpData.xDone THEN
					writeDirectOpData.xExecute := FALSE;
					state := eOrientalAZDriveStates.Moving;
				ELSIF writeDirectOpData.xError THEN
					writeDirectOpData.xExecute := FALSE;
					state := eOrientalAZDriveStates.Faulting;
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
				IF writeDirectOpData.xDone THEN
					writeDirectOpData.xExecute := FALSE;
					state := eOrientalAZDriveStates.Moving;
				ELSIF writeDirectOpData.xError THEN
					writeDirectOpData.xExecute := FALSE;
					state := eOrientalAZDriveStates.Faulting;
				END_IF
				
		eOrientalAZDriveStates.Jogging:
				// Jog forward/reverse
				jogForward := jogForwardCMD;
				jogReverse := jogReverseCMD;
				
				IF NOT jogForward AND NOT jogReverse THEN
					state := eOrientalAZDriveStates.Idle;
				END_IF
		
		eOrientalAZDriveStates.Moving:
				// After sending data, we are moving
				IF inPosition OR (atTorqueLimit AND MoveAbsTorque) THEN
					TargetReached := TRUE;
					state := eOrientalAZDriveStates.DoneMoving;
				END_IF
		
		eOrientalAZDriveStates.DoneMoving:
				// Wait for status to clear
				IF NOT MoveAbs AND NOT MoveAbsTorque AND NOT MoveRel THEN
					state := eOrientalAZDriveStates.Idle;
				END_IF 
			
		
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
					IF alarmActive THEN
						reset := TRUE;
					END_IF
					IF NOT alarmActive THEN
						state := eOrientalAZDriveStates.Idle;
					END_IF
					
				END_IF
END_CASE
