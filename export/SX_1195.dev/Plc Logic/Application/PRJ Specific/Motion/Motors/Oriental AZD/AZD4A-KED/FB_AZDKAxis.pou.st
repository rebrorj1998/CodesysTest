(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AZDKAxis EXTENDS FB_AZDKABase
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_TLCOns : FB_ONS;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_AZDOrientalMotor
//  FB/FB_AZSampleMotor
//
//  Created by Evan Ische on 07/01/2022.
//  Copyright (C) 2022 Sharp Packaging Systems By Pregis. All rights reserved.
//

SUPER^();

// On rising edge of the reset, clear out the state engine
IF _resetONS.OSR THEN
	_state := eAxisREFMotionState.Idle;
END_IF
_TLCOns(CLK := _statusword.TLC AND (_state = eAxisREFMotionState.MovingAbsolute OR _state = eAxisREFMotionState.MovingRelative));
CASE _state OF
	eAxisREFMotionState.Idle:
		_controlword.NewSetPoint := FALSE;
		IF _absoluteONS.OSR THEN
			_state := eAxisREFMotionState.MoveAbsolute;
			_controlword.PPMode := eDiscreteMotionType.Absolute;
			_controlword.Push := FALSE;
		ELSIF _absoluteTorqueONS.OSR THEN
			_state := eAxisREFMotionState.MoveAbsolute;
			_controlword.PPMode := eDiscreteMotionType.Absolute;
			_controlword.Push := TRUE;
		ELSIF _relativeONS.OSR THEN
			_state := eAxisREFMotionState.MoveRelative;
			_controlword.PPMode := eDiscreteMotionType.Relative;
		ELSIF _haltONS.Q THEN
			_state := eAxisREFMotionState.Halt;
		ELSIF _homeONS.OSR THEN
			_state := eAxisREFMotionState.Homing;
		END_IF
		targetReached := FALSE;
		
	
	eAxisREFMotionState.Jog,
	eAxisREFMotionState.MoveRelative,
	eAxisREFMotionState.MoveAbsolute: //
		_controlword.NewSetPoint := TRUE;
		IF _statusword.setpointAcknowledge THEN
			_controlword.NewSetPoint := FALSE;
			_state := eAxisREFMotionState.MovingAbsolute;
		END_IF
		
	eAxisREFMotionState.MovingAbsolute,
	eAxisREFMotionState.MovingRelative: //
		IF _statusword.targetReached OR (_controlword.Push AND _TLCOns.OSR) THEN
			targetReached := TRUE;
			_state := eAxisREFMotionState.Idle;
		END_IF
														
	eAxisREFMotionState.Halt: // Stop any active sequence
		_controlword.Halt := TRUE;
		_controlword.Push := FALSE;
		IF _statusword.targetReached THEN
			_controlword.Halt := FALSE;
			_state := eAxisREFMotionState.Idle;
		END_IF
	
	eAxisREFMotionState.Homing: // Home Motor
		_controlword.HomingOperationStart := TRUE;
		IF _statusword.homingAttained THEN
			_controlword.HomingOperationStart := FALSE;
			_state := eAxisREFMotionState.Idle;
		END_IF
END_CASE