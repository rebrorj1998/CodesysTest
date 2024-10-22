(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AZDKABase EXTENDS Axis_REF
VAR_INPUT
	jogForwardCMD : BOOL;
	jogReverseCMD : BOOL;
	iErrorCode : UINT;
	iModeOfOperation : SINT;
	iStatusword : UINT;
	iActualVelocity : DINT;
	iActualPosition : DINT;
END_VAR
VAR_OUTPUT
	oControlword : UINT;
	oModeOfOperation : eAZDProfileMode;
	oTargetPosition : DINT;
	oProfileVelocity : UDINT;
	oProfileAcceleration : UDINT;
	oProfileDeceleration : UDINT;
	oProfilePushCurrent : INT;
	oProfileOperationalCurrent : INT;
	alarmCode : eOrientalAZDriveFaults;
	actualPositonInInches : REAL;
END_VAR
VAR
	_resetONS : FB_ONS;
	_jogForwardONS : FB_ONS;
	_jogReverseONS : FB_ONS;
	_relativeONS : FB_ONS;
	_zHomeONS : FB_ONS;
	_absoluteONS : FB_ONS;
	_absoluteTorqueONS : FB_ONS;
	_homeONS : FB_ONS;
	_errorONS : FB_ONS;
	_haltONS : Standard.R_TRIG;
	_statusword : FB_AZDStatus;
	_controlword : FB_AZDControl;
	_state : eAxisREFMotionState;
	_startupState : eAZDPowerupState;
	_motorExcitationDelayTimer : Standard.TON := (PT := T#250MS);
	_resetSignalPulseTON : Standard.TON := (PT := T#50MS);
	_codetemp : DWORD;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_AZDOrientalMotor
//  FB/FB_AZDOrientalMotor
//
//  Created by Evan Ische on 6/13/2022.
//  Copyright (C) 2022 Sharp Packaging Systems By Pregis. All rights reserved.
//

//
operational := EnableAxisOps();
	
//
_resetSignalPulseTON.IN := ackError;
_resetONS(CLK := ackError);
_controlword.FaultReset := _statusword.fault AND ackError AND NOT _resetSignalPulseTON.Q;

//diagnostic code - delete me
IF _statusword.fault AND ackError AND NOT _resetSignalPulseTON.Q THEN
	_codetemp := _codetemp;
END_IF

// Status bits read from the AZD4A drive
_statusword(
	mode := modeOfOperation,
	data := iStatusword);

// Control bits written to the AZD4A drive
_controlword(
	mode := modeOfOperation,
	data => oControlword
);

// Active Alarm
alarmCode := OSCAT_BASIC.BYTE_OF_DWORD(iErrorCode,0);
isHomed := _statusword.homingAttained;
IF alarmCode <> 0 THEN
	_codetemp := alarmCode;
END_IF
_errorONS(CLK := _statusword.fault);

error := _statusword.fault;
// IF _errorONS.OSR THEN
// 	error := TRUE;
// END_IF
// Convert Distance setpoint to steps.  Reverse polarity for display purposes if needed. 
actualPositonInInches := (actPos / TO_REAL(axisData.config.stepsPerInch));
IF axisData.config.reversePolarity THEN
    actualPositonInInches := actualPositonInInches * -1; 
END_IF

// Perform move on rising edge
_haltONS(CLK := Halt);
_relativeONS(CLK := MoveRel);
_absoluteONS(CLK := MoveAbs);
_absoluteTorqueONS(CLK := moveAbsTorque);
_homeONS(CLK := startHoming);
IF _homeONS.OSR THEN
	_controlword.HomingOperationStart:=TRUE;
END_IF
// Write data from drive to local variables
actPos := TO_REAL(iActualPosition) + zeroOffset * axisData.config.stepsPerInch;
actVel := TO_REAL(iActualVelocity);

// Write data to drive from local variables
oTargetPosition := TO_DINT(TargetPositionInSteps);
oProfileVelocity := TO_UDINT(ProfileVelocityInEngUnits);
oProfileAcceleration := TO_UDINT(EngUnitsToHz(ProfileAcceleration));
oProfileDeceleration := TO_UDINT(EngUnitsToHz(ProfileDeceleration));
oProfilePushCurrent := TO_INT(profilePushCurrentLimit * 10.0);
IF push THEN
	oProfileOperationalCurrent := TO_INT(defaultCurrent * 10.0);
ELSE
	oProfileOperationalCurrent := TO_INT(profileCurrentLimit * 10.0);	
	IF oProfileOperationalCurrent = 0 THEN
		oProfileOperationalCurrent := TO_INT(defaultCurrent * 10.0);
	END_IF
END_IF

oModeOfOperation := modeOfOperation;

// On rising edge start moving, on falling edge halt 
_jogForwardONS(CLK := jogForwardCMD);
_jogReverseONS(CLK := jogReverseCMD);
IF _jogForwardONS.OSR OR _jogReverseONS.OSR THEN
	CASE axisData.jogType OF
		eDiscreteMotionType.Relative:
			profileAcceleration := jogProfile.acceleration;
			profileDeceleration := jogProfile.deceleration;
			profileVelocity := jogProfile.velocity;
			targetPosDist := jogProfile.position;
			profileCurrentLimit := jogProfile.current;
			IF _jogReverseONS.OSR THEN
				targetPosDist := targetPosDist * -1;
			END_IF
			_controlword.PPMode := eDiscreteMotionType.Relative;
		eDiscreteMotionType.Absolute:
			profileAcceleration := jogProfile.acceleration;
			profileDeceleration := jogProfile.deceleration;
			profileVelocity := jogProfile.velocity;
			targetPosDist := jogProfile.maxPosition;
			profileCurrentLimit := jogProfile.current;
			IF _jogReverseONS.OSR THEN
				targetPosDist := jogProfile.minPosition;
			END_IF
			_controlword.PPMode := eDiscreteMotionType.Absolute;
	END_CASE
	_state := eAxisREFMotionState.Jog;
ELSIF _jogForwardONS.OSF OR _jogReverseONS.OSF OR _haltONS.Q THEN
	_state := eAxisREFMotionState.Halt;
END_IF
