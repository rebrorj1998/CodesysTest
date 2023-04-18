(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseAppliedMotionMotorEIP EXTENDS Axis_REF
VAR_INPUT
	stepsPerInch : DINT;
	rotationsPerInch : REAL;
	reversePolarity : BOOL;
	serviceJogForward : BOOL;
	serviceJogReverse : BOOL;
	homingSensorClear : BOOL;
	commsFailure : BOOL;
	joggingParameters : Jog;
	homingParameters : MotionParameters;
	motorResetState : eMotorResetStates;
	dataFromDrive : POINTER TO DINT;
    dataToDrive : POINTER TO DINT;
END_VAR
VAR_OUTPUT
	alarmCode: INT;
    statusCode : INT;
	actualPositonInInches : REAL;
END_VAR
VAR
	_haltONS : FB_ONS;
	_homeONS: FB_ONS;
	_jogForwardONS : FB_ONS;
	_jogReverseONS : FB_ONS;
	_resetONS : FB_ONS;
	_moveRelONS : FB_ONS;
	_moveAbsONS : FB_ONS;
	_sclCommand : DINT;				        
	_parameter1 : DINT;					    
	_parameter2 : DINT;					    
	_commands : FB_StepServoCommands;
	_status : FB_StepServoStatus;
	_state : eAxisREFMotionState;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_BaseAppliedMotionMotorEIP
//  Motion/Motors/AppliedMotion/Applied Motion TSM34IP-3DG/FB_BaseAppliedMotionMotorEIP
//
//  Created by Evan Ische on 8/13/2021.
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

// Step servo command bits handler
_commands();

// If Motor Faulted, Continue to Write Reset Fault Commands 
_resetONS(CLK := AckError);
CASE motorResetState OF
	eMotorResetStates.Idle:
		IF _resetONS.OSR THEN
			motorResetState := eMotorResetStates.Reset;
		END_IF
	eMotorResetStates.Reset:
		_commands.AlarmReset := TRUE;
		IF _commands.commandSuccessful THEN
			motorResetState := eMotorResetStates.Enable;
		END_IF
	eMotorResetStates.Enable:
		_commands.Enable := TRUE;
		IF _commands.commandSuccessful THEN
			motorResetState := eMotorResetStates.Idle;
		END_IF
END_CASE

// Reset the homing bit whenever off/e-stopped
IF commsFailure THEN
	isHomed := FALSE;
END_IF

// Initalize current limit
IF profileCurrentLimit = 0 THEN
	profileCurrentLimit := defaultCurrent;
END_IF

// Actual current limit has reached set maximum
currentLimitReached := alarmCode.13;

// Write EIP Registers To Parameters
statusCode := DINT_TO_INT(dataFromDrive[0]);
alarmCode  := DINT_TO_INT(dataFromDrive[1]);
actPos     := TO_REAL(dataFromDrive[6]);
actVel     := TO_REAL(dataFromDrive[8]);

// Write Paramters to EIP Registers
dataToDrive[04] := TO_DINT(ScaledProfileVelocity);
dataToDrive[05] := TO_DINT(profileAcceleration);
dataToDrive[06] := TO_DINT(profileDeceleration);
dataToDrive[07] := TO_DINT(ScaledProfileTargetPostion);
dataToDrive[08] := TO_DINT(profileCurrentLimit);
dataToDrive[09] := TO_DINT(_sclCommand);
dataToDrive[10] := TO_DINT(_parameter1);
dataToDrive[11] := TO_DINT(_parameter2);
dataToDrive[12] := TO_DINT(profileCurrentLimit);
dataToDrive[13] := TO_DINT(profileCurrentLimit) + 1;
dataToDrive[00] := _commands.commandWord;

// Get drive data directly from master axis
_status(statusCode := statusCode);
IF NOT _status.moving THEN 
	actVel := 0;
END_IF

//Convert Distance setpoint to steps.  Reverse polarity for display purposes if needed. 
actualPositonInInches := (actPos / DINT_TO_REAL(stepsPerInch));
IF reversePolarity THEN
    actualPositonInInches := actualPositonInInches * -1; 
END_IF

// For use in any class that extends this class
_haltONS(CLK := Halt);
_moveRelONS(CLK := MoveRel);
_moveAbsONS(CLK := MoveAbs);
_homeONS(CLK := StartHoming);

// On rising edge start moving, on falling edge halt 
_jogForwardONS(CLK := serviceJogForward);
_jogReverseONS(CLK := serviceJogReverse);
IF _jogForwardONS.OSR OR _jogReverseONS.OSR THEN
	CASE joggingParameters.jogType OF
		eDiscreteMotionType.Relative:
			profileAcceleration := joggingParameters.relative.acceleration;
			profileDeceleration := joggingParameters.relative.deceleration;
			profileVelocity := joggingParameters.relative.velocity;
			targetPosDist := joggingParameters.relative.position;
			IF _jogReverseONS.OSR THEN
				targetPosDist := targetPosDist * -1;
			END_IF
		eDiscreteMotionType.Absolute:
			profileAcceleration := joggingParameters.absolute.acceleration;
			profileDeceleration := joggingParameters.absolute.deceleration;
			profileVelocity := joggingParameters.absolute.velocity;
			targetPosDist := joggingParameters.absolute.maxPosition;
			IF _jogReverseONS.OSR THEN
				targetPosDist := joggingParameters.absolute.minPosition;
			END_IF
	END_CASE
	_state := eAxisREFMotionState.Jog;
ELSIF _jogForwardONS.OSF OR _jogReverseONS.OSF OR _haltONS.OSR THEN
	_state := eAxisREFMotionState.Halt;
END_IF
