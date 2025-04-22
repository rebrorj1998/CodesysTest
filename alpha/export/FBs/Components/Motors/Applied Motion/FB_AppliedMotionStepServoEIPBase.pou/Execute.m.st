(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: AppliedMotionStepServo
//    Description: This block provides an abstraction for a Ethernet I/P Applied Motion Step Servo
//    Created by: Ben Hess
//    Created Date: May 11th, 2018

// Use pointers for EIP memory register locations
driveInputs := ptrEIPInputs^;
// Step servo command bits handler
commands();
ptrEIPOutputs^ := driveOutputs;
alarms(alarmCode := stepServoAlarmCodeRaw, faults := faults);

IF currentLimit = 0 THEN 
	currentLimit := defaultCurrentSetpoint;
END_IF
//Map raw EIP Registers to parameters
//absolutePositionSteps := driveInputs[5];
absolutePositionSteps := driveInputs[5];
velocity := DINT_TO_INT(driveInputs[8]);
stepServoStatusRaw := DINT_TO_INT(driveInputs[0]);
stepServoAlarmCodeRaw := DINT_TO_INT(driveInputs[1]);
driveOutputs[4] := velocitySetpoint;
driveOutputs[5] := pointToPointAccelSetpoint;
driveOutputs[6] := pointToPointDecelSetpoint;
driveOutputs[7] := distanceToMoveInSteps;
driveOutputs[8] := currentLimit;
driveOutputs[9] := sclCommand;
driveOutputs[10] := parameter1;
driveOutputs[11] := parameter2;
driveOutputs[12] := currentLimit;
driveOutputs[13] := currentLimit;
driveOutputs[0] := commands.commandWord;

//Convert Distance setpoint to steps.  Reverse polarity for display purposes if needed. 

absolutePositonInches := (DINT_TO_REAL(absolutePositionSteps) / INT_TO_REAL(stepsPerInchSetpoint));

//Homing required from motor - for now just if there was an initialization seen.
homeRequiredIndication S= status.initializing OR Globals.firstScan OR _faulted OR driveInputs[11].0;
//homeRequiredIndication S= status.initializing OR Globals.firstScan OR driveInputs[11].0;
homingOSF(CLK := status.homing);
IF NOT driveInputs[11].0 THEN
	homeRequiredIndication := FALSE;
END_IF

commandSentONS(CLK := commands.commandSent);

IF commandSentONS.Q THEN
	commandSuccessful := TRUE;
END_IF

commandSuccessfulONS(CLK := commandSuccessful);
IF commandSuccessfulONS.Q THEN
	//parameter1 := 0;
	//velocitySetpoint := 0;
	//pointToPointAccelSetpoint := 0;
	//pointToPointDecelSetpoint := 0;
	//distanceToMoveInSteps := 0;
END_IF

resetTimeout(IN := _reset, PT := T#1S);
encoderResetTimeout(PT := T#150MS);
IF resetTimeout.Q THEN
	resetState := 0;
	encoderResetTimeout.IN := FALSE;
	_reset := FALSE;
END_IF
CASE resetState OF
	
	0 :		// Do Nothing
			IF _reset THEN
				resetState := 1;
			END_IF
	1 :		// 
			commandSuccessful := FALSE;
			commands.alarmReset := TRUE;
			resetState := 2;
	
	2 :		IF commandSuccessful THEN
				commandSuccessful := FALSE;
				commands.Enable := TRUE;
				resetState := 3;		
			END_IF
	
	3 :		//
			IF commandSuccessful THEN;
				encoderResetTimeout.IN := TRUE;
				IF encoderResetTimeout.Q THEN
					resetState := 4;	
					ResetEncoderPosition(driveInputs[5]);	
				END_IF
			END_IF
	
	4 :		//
			IF commandSuccessful THEN;
				resetState := 0;
				_reset := FALSE;
			END_IF
END_CASE

IF reversePolarity THEN
    absolutePositonInches := absolutePositonInches * -1; 
END_IF
absolutePositonInches := absolutePositonInches + positionOffset;

//Get Servo Status and unpack
status(statusCode := StepServoStatusRaw);

//Bit-packing for LONG types over Modbus
//_faulted := status.driveFaulted OR status.alarmPresent OR commFail;
_faulted := status.driveFaulted OR commFail;

//Manual moves for motor
IF moveDistanceManualPB THEN
    MoveDistance(distance := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    moveDistanceManualPB := FALSE;
END_IF

IF movePositionManualPB THEN
    MoveToPosition(position := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    movePositionManualPB := FALSE;
END_IF


faults.commFail.faultTrigger := commFail; //AND Globals.machinePowerOK;
//faults.notHomed.faultTrigger := homeRequiredIndication AND isHomable;

