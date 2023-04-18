(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionMotorMB EXTENDS Axis_REF
VAR_INPUT
	modbusAddress : USINT;
	stepsPerInchSP : DINT := 3999;
	zeroOffset : REAL;
	jogForwardCMD : BOOL;
	jogReverseCMD : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	directDataOp : sctAppliedMotionPars;
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
	
	modbusWriteResponse : ARRAY[0..20] OF WORD;
	readData : IoDrvModbus.ModbusChannel;
	readDataAfterWrite : IoDrvModbus.ModbusChannel;
	//readDataMBCommand : IoDrvModbus.ModbusCommand;
	writeParameters : IoDrvModbus.ModbusChannel;
  	//writeDirectOpDataMBCommand : IoDrvModbus.ModbusCommand;
	writeOpcode : IoDrvModbus.ModbusChannel;
  	//writeRIODataMBCommand : IoDrvModbus.ModbusCommand;
   	readRateTimer : Standard.TON := (PT:= T#200MS);
	readAfterDDWrite : FB_ONS;
	readAfterRIOWrite : FB_ONS;
	haltONS : FB_ONS;
	triggerRIOWrite : BOOL;
	(*Temp for testing*)
	triggerNow : BOOL;
	disable : BOOL;
	status : FB_AppliedMotionStatus;
	alarms : FB_AppliedMotionAlarms;
	state : eAppliedMotionDriveStates;
	
END_VAR
VAR_IN_OUT
	MBChannel : IoDrvModbus.ModbusSlaveComPort;
	modbusDataFromDrive : ARRAY[0..19] OF WORD;
	modbusParDataToDrive : ARRAY[0..4] OF WORD;
	modbusOpcodeToDrive : ARRAY[0..1] OF WORD;
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
modbusParDataToDrive[0] := directDataOp.Accel;
modbusParDataToDrive[1] := directDataOp.Decel;
modbusParDataToDrive[2] := directDataOp.Speed;
modbusParDataToDrive[3] := directDataOp.Position.wWord[1];
modbusParDataToDrive[4] := directDataOp.Position.wWord[0];

// Get raw drive position

distanceFromDrive.wWord[0] := modbusDataFromDrive[7];
distanceFromDrive.wWord[1] := modbusDataFromDrive[6];
ActPos := (TO_REAL(distanceFromDrive.diDint) / TO_REAL(stepsPerInchSP)) + zeroOffset;





// Trigger an RIO write whenever it changes



writeOpcode(
	slave:= MBChannel, 
	xExecute:= , 
	xAbort:= , 
	iChannelIndex:= 2, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );

writeParameters(
	slave:= MBChannel, 
	xExecute:= , 
	xAbort:= , 
	iChannelIndex:= 1, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );
	
// Read registers from drive
// On a cyclic basis	
readRateTimer(IN := NOT readRateTimer.Q AND NOT (writeOpcode.xBusy OR writeParameters.xBusy OR readData.xBusy OR readDataAfterWrite.xBusy));
// And directly after a DD op write
readAfterDDWrite(CLK := writeParameters.xDone);
readAfterRIOWrite(CLK := writeOpcode.xDone);

readData(
	slave:= MBChannel, 
	xExecute:= readRateTimer.Q OR readData.xBusy, 
	xAbort:= , 
	iChannelIndex:= 0, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );


	
readDataAfterWrite(
	slave:= MBChannel, 
	xExecute:= writeOpcode.xDone, 
	xAbort:= , 
	iChannelIndex:= 0, 
	xBusy=> , 
	xDone=> , 
	xError=> , 
	xAborted=> , 
	ModbusError=> );
	
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

status(statusCode := modbusDataFromDrive[1]);
alarms(alarmCode := modbusDataFromDrive[0]);
// Get drive data directly from modbus or from master axis	

Ready := status.motorEnabled;
AlarmActive := status.driveFaulted;
Moving := status.moving;
InPosition := status.inPosition;


haltONS(CLK := Halt);
IF haltONS.OSR THEN
	state := eAppliedMotionDriveStates.Faulting;
END_IF

IF alarmActive THEN
	state := eAppliedMotionDriveStates.Faulting;
END_IF


CASE state OF
	eAppliedMotionDriveStates.Idle:
				// 	Idle state, wait for command
				mClearStatus();
				IF MoveAbs THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStates.MoveABS;
				ELSIF MoveRel THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStates.MoveInc;
				ELSIF MoveAbsTorque THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStates.MoveABS;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					state := eAppliedMotionDriveStates.Jogging;
				ELSIF StartHoming THEN
					//AxisState := AXIS_STATE.AS_Homing;
					state := eAppliedMotionDriveStates.Home;
				END_IF

	eAppliedMotionDriveStates.MoveABS:
				// Move to absolute position
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.Accel := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.Decel := mVeloAccDecCalc(ProfileDeceleration);
				modbusOpcodeToDrive[0] := TO_WORD(eAppliedMotionOpcodes.FEED_TO_POSITION);
				writeParameters.xExecute := TRUE;
				IF writeParameters.xDone THEN
					writeParameters.xExecute := FALSE;
					state := eAppliedMotionDriveStates.SendOpcodeAfterPars;
				ELSIF writeParameters.xError THEN
					writeParameters.xExecute := FALSE;
					state := eAppliedMotionDriveStates.Faulting;
				END_IF
		
				
		eAppliedMotionDriveStates.MoveInc:
				// Move to absolute position
				directDataOp.Position.diDint := mDistanceCalc(TargetPosDist);
				directDataOp.Speed := mVeloAccDecCalc(ProfileVelocity);
				directDataOp.Accel := mVeloAccDecCalc(ProfileAcceleration);
				directDataOp.Decel := mVeloAccDecCalc(ProfileDeceleration);
				modbusOpcodeToDrive[0] := TO_WORD(eAppliedMotionOpcodes.FEED_TO_LENGTH);
				writeParameters.xExecute := TRUE;
				IF writeParameters.xDone THEN
					writeParameters.xExecute := FALSE;
					state := eAppliedMotionDriveStates.Moving;
				ELSIF writeParameters.xError THEN
					writeParameters.xExecute := FALSE;
					state := eAppliedMotionDriveStates.Faulting;
				END_IF		
		
		eAppliedMotionDriveStates.Home:
				//
				zHome := TRUE;
				IF writeOpcode.xDone THEN
					state := eAppliedMotionDriveStates.Homing;
				ELSIF writeOpcode.xError THEN
					state := eAppliedMotionDriveStates.Faulting;
				END_IF
				
		
		eAppliedMotionDriveStates.Homing:		
				//
				IF inPosition THEN
					zHome := FALSE;
					HomingDone := TRUE;
					state := eAppliedMotionDriveStates.DoneMoving;
				END_IF
				
		eAppliedMotionDriveStates.Jogging:
				// Jog forward/reverse
				jogForward := jogForwardCMD;
				jogReverse := jogReverseCMD;
				IF NOT jogForward AND NOT jogReverse THEN
					state := eAppliedMotionDriveStates.Idle;
				END_IF
		eAppliedMotionDriveStates.SendOpcodeAfterPars:
				// 
				writeOpcode.xExecute := TRUE;
				IF writeParameters.xDone AND readDataAfterWrite.xDone THEN
					writeOpcode.xExecute := FALSE;
					state := eAppliedMotionDriveStates.Moving;
				ELSIF writeOpcode.xError THEN
					writeOpcode.xExecute := FALSE;
					state := eAppliedMotionDriveStates.Faulting;
				END_IF		
				
		eAppliedMotionDriveStates.Moving:
				// After sending data, we are moving
				IF inPosition OR (atTorqueLimit AND MoveAbsTorque) THEN
					TargetReached := TRUE;
					state := eAppliedMotionDriveStates.DoneMoving;
				END_IF
		
		eAppliedMotionDriveStates.DoneMoving:
				// Wait for status to clear
				IF NOT MoveAbs AND NOT MoveAbsTorque AND NOT MoveRel AND NOT StartHoming THEN
					AxisState := AXIS_STATE.AS_Standstill;
					state := eAppliedMotionDriveStates.Idle;
				END_IF 

		eAppliedMotionDriveStates.Faulting:
				// Faulting - stop drive
				mClearStatus();
				AxisState := AXIS_STATE.AS_ErrorStop;
				Error := TRUE;
				freeMotor := TRUE;
				state := eAppliedMotionDriveStates.Faulted;
				
		eAppliedMotionDriveStates.Faulted:
				// Faulted - wait for clear
				IF AckError THEN
					IF alarmActive THEN
						reset := TRUE;
					END_IF
					IF NOT alarmActive THEN
						state := eAppliedMotionDriveStates.Idle;
					END_IF
				END_IF
END_CASE
