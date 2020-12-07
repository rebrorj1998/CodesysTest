(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionMotorASCII EXTENDS Axis_REF
VAR_INPUT
	modbusAddress : USINT;
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
	readStatusState : INT;
	modbusWriteResponse : ARRAY[0..20] OF WORD;
	
  	//writeRIODataMBCommand : IoDrvModbus.ModbusCommand;
   	readRateTimer : Standard.TON := (PT:= T#50MS);
	waitForHaltTimer : Standard.TON := (PT := T#20MS);
	readAfterDDWrite : FB_ONS;
	readAfterRIOWrite : FB_ONS;
	haltONS : FB_ONS;
	triggerRIOWrite : BOOL;
	(*Temp for testing*)
	triggerNow : BOOL;
	disable : BOOL;
	status : FB_AppliedMotionStatus;
	alarms : FB_AppliedMotionAlarms;
	state : eAppliedMotionDriveStatesASCII;
	alarmONS : FB_ONS;
	//testing and troubleshooting
	tryWeirdString : BOOL;
	weirdString : STRING;
	result : DWORD;
END_VAR
VAR_IN_OUT
	asciiHandler : FB_CrevisSerial;
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
	asciiHandler.xExecute := FALSE;
	asciiHandler();
	state := eAppliedMotionDriveStatesASCII.Halt;
END_IF

readRateTimer(IN := (state = eAppliedMotionDriveStatesASCII.Moving) AND NOT readRateTimer.Q);
waitForHaltTimer(IN := state = eAppliedMotionDriveStatesASCII.Halting);


CASE readStatusState OF
	0: 	//Idle
		IF readRateTimer.Q AND NOT asciiHandler.xExecute THEN
			asciiHandler.sendData := '2SC$R';
			asciiHandler.xExecute := TRUE;
			readStatusState := 1;
		END_IF
		IF haltONS.OSR THEN
			asciiHandler.xExecute := FALSE;
		END_IF
		
	1:	// Parse Status word
		IF asciiHandler.xDone THEN
			asciiHandler.xExecute := FALSE;
			status(statusCode := TO_WORD(mParseStatusWord(asciiHandler.receivedData)));
			readStatusState := 0;
		END_IF
		
		IF haltONS.OSR THEN
			readStatusState := 0;
			asciiHandler.xExecute := FALSE;
		END_IF
END_CASE

IF tryWeirdString THEN
	tryWeirdString := FALSE;
	result := mParseStatusWord(weirdString);
END_IF

// Get drive data directly from modbus or from master axis	
Ready := status.motorEnabled;
AlarmActive := status.driveFaulted;
Moving := status.moving;
InPosition := status.inPosition;

IF moving THEN 
	ActVelocity := ProfileVelocity;
ELSE
	ActVelocity := 0;
END_IF


alarmONS(CLK := alarmActive);
IF alarmONS.OSR THEN
	Error := TRUE;
	state := eAppliedMotionDriveStatesASCII.Faulting;
END_IF


CASE state OF
	eAppliedMotionDriveStatesASCII.Idle:
				// 	Idle state, wait for command
				mClearStatus();
				IF MoveAbs THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStatesASCII.MoveABS;
				ELSIF MoveRel THEN
					asciiHandler.sendData := (CONCAT('2VE', mVeloAccDecCalc(ProfileVelocity)));
					asciiHandler.xExecute := TRUE;
					IF asciiHandler.xDone THEN
						asciiHandler.xExecute := FALSE;
						AxisState := AXIS_STATE.AS_DiscreteMotion;
						state := eAppliedMotionDriveStatesASCII.MoveInc;
					END_IF
					
				ELSIF MoveAbsTorque THEN
					AxisState := AXIS_STATE.AS_DiscreteMotion;
					state := eAppliedMotionDriveStatesASCII.MoveABS;
				ELSIF jogForwardCMD OR jogReverseCMD THEN
					asciiHandler.sendData := (CONCAT('2VE', mVeloAccDecCalc(1)));
					asciiHandler.xExecute := TRUE;
					IF asciiHandler.xDone THEN
						asciiHandler.xExecute := FALSE;
						AxisState := AXIS_STATE.AS_DiscreteMotion;
						state := eAppliedMotionDriveStatesASCII.StartJogging;
					END_IF
					
				ELSIF StartHoming THEN
					//AxisState := AXIS_STATE.AS_Homing;
					state := eAppliedMotionDriveStatesASCII.Home;
				END_IF

		eAppliedMotionDriveStatesASCII.MoveABS:
				// Move to absolute position
				
				
		
				
		eAppliedMotionDriveStatesASCII.MoveInc:
				// Move to incremental position
				asciiHandler.sendData := (CONCAT('2FL', mDistanceCalc(TargetPosDist)));
				asciiHandler.xExecute := TRUE;
				IF asciiHandler.xDone THEN
					asciiHandler.xExecute := FALSE;
					state := eAppliedMotionDriveStatesASCII.Moving;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Home:
				//
				
				
		
		eAppliedMotionDriveStatesASCII.Homing:		
				//
				IF inPosition THEN
					zHome := FALSE;
					HomingDone := TRUE;
					state := eAppliedMotionDriveStatesASCII.DoneMoving;
				END_IF
		
		eAppliedMotionDriveStatesASCII.StartJogging:
				// 
				IF jogForwardCMD THEN
					asciiHandler.sendData := (CONCAT('2FL', mDistanceCalc(30)));
					asciiHandler.xExecute := TRUE;
					IF asciiHandler.xDone THEN
						asciiHandler.xExecute := FALSE;
						state := eAppliedMotionDriveStatesASCII.Jogging;
					END_IF
				ELSIF jogReverseCMD THEN
					asciiHandler.sendData := (CONCAT('2FL', mDistanceCalc(-30)));
					asciiHandler.xExecute := TRUE;
					IF asciiHandler.xDone THEN
						asciiHandler.xExecute := FALSE;
						state := eAppliedMotionDriveStatesASCII.Jogging;
					END_IF
				ELSE
					asciiHandler.xExecute := FALSE;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Jogging:
				// Jog forward/reverse
				IF NOT jogForwardCMD AND NOT jogReverseCMD THEN
					asciiHandler.sendData := ('2ST$R');
					asciiHandler.xExecute := TRUE;
					IF asciiHandler.xDone THEN
						asciiHandler.xExecute := FALSE;
						state := eAppliedMotionDriveStatesASCII.Idle;
					END_IF
					
				END_IF
		eAppliedMotionDriveStatesASCII.SendOpcodeAfterPars:
				// 
				
				
		eAppliedMotionDriveStatesASCII.Moving:
				// After sending data, we are moving
				ActVelocity := ProfileVelocity;
				IF inPosition AND asciiHandler.xDone THEN
					TargetReached := TRUE;
					asciiHandler.xExecute := FALSE;
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
				
				IF NOT asciiHandler.xExecute THEN
					asciiHandler.sendData := ('2ST$R');
					asciiHandler.xExecute := TRUE;
					state := eAppliedMotionDriveStatesASCII.Halting;
				END_IF
				
				
				
		eAppliedMotionDriveStatesASCII.HaltSending:
				//
				IF asciiHandler.xDone THEN
					asciiHandler.xExecute := FALSE;
					state := eAppliedMotionDriveStatesASCII.Halting;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Halting:
				//		
				
				IF waitForHaltTimer.Q THEN
					asciiHandler.xExecute := FALSE;
					ActVelocity := 0;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF
		
				
		eAppliedMotionDriveStatesASCII.Faulting:
				// Faulting - stop drive
				mClearStatus();
				AxisState := AXIS_STATE.AS_ErrorStop;
				Error := TRUE;
				freeMotor := TRUE;
				asciiHandler.sendData := ('2ST$R');
				asciiHandler.xExecute := TRUE;
				IF asciiHandler.xDone THEN
					asciiHandler.xExecute := FALSE;
					state := eAppliedMotionDriveStatesASCII.FaultGetAlarmCode;
				END_IF
		
		eAppliedMotionDriveStatesASCII.FaultGetAlarmCode:
				// Get alarm code and display
				asciiHandler.sendData := ('2AL$R');
				asciiHandler.xExecute := TRUE;
				IF asciiHandler.xDone THEN
					asciiHandler.xExecute := FALSE;
					alarms(alarmCode := TO_WORD((mParseStatusWord(asciiHandler.receivedData))));
					state := eAppliedMotionDriveStatesASCII.EnableMotor;
				END_IF
		
		eAppliedMotionDriveStatesASCII.Faulted:
				// Faulted - wait for clear
				IF AckError THEN
					IF alarmActive THEN
						asciiHandler.sendData := ('2AX$R');
						asciiHandler.xExecute := TRUE;
						IF asciiHandler.xDone THEN
							asciiHandler.xExecute := FALSE;
							state := eAppliedMotionDriveStatesASCII.EnableMotor;
						END_IF
					ELSE
						state := eAppliedMotionDriveStatesASCII.Idle;
					END_IF
					
				END_IF
				
		eAppliedMotionDriveStatesASCII.EnableMotor:
				//
				asciiHandler.sendData := ('2ME$R');
				asciiHandler.xExecute := TRUE;
				IF asciiHandler.xDone THEN
					asciiHandler.xExecute := FALSE;
					Error := FALSE;
					state := eAppliedMotionDriveStatesASCII.Idle;
				END_IF
END_CASE

alarmCode := alarms.alarmCode;
statusCode := status.statusCode;
