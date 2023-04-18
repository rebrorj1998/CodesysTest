(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SealFlattenerAppliedMotionMotorEIP EXTENDS FB_BaseAppliedMotionMotorEIP
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_SealFlattenerAppliedMotionMotorEIP()
//	Description: A PLCOpen Motion compliant library for a Oriental AZ Series drive/motor			 
//	Created by: Evan Ische
//	Created Date: Tuesday, October 13th 2020

// Outputs for Motion Lib
operational := PowerOn;
enableState := DriveEnable;

// Exit if drive isn't enabled.
IF NOT driveEnable THEN
	RETURN;
END_IF

SUPER^();

// On rising edge of the reset, nil out the state engine
IF _resetONS.OSR THEN
	_state := eAxisREFMotionState.Halt;
END_IF

CASE _state OF
	eAxisREFMotionState.Idle: // Idle state, wait for command
		targetReached := FALSE;
		IF _moveAbsONS.OSR THEN
			_state := eAxisREFMotionState.MoveAbsolute;
		ELSIF _homeONS.OSR THEN
			_state := eAxisREFMotionState.Home;
		END_IF
		SUPER^.ClearMotorCommand();
		
	eAxisREFMotionState.Home: //
		SUPER^.ExecuteStoredProgram(1);
		IF _commands.commandSuccessful THEN
			_state := eAxisREFMotionState.Homing;
		END_IF
		
	eAxisREFMotionState.Homing: //
		IF NOT _status.homing THEN
			_state := eAxisREFMotionState.Idle;
			isHomed := TRUE;
		END_IF
		
	eAxisREFMotionState.Jog,	
	eAxisREFMotionState.MoveAbsolute: //
		_commands.FeedToPosition := TRUE;
		IF _commands.commandSuccessful THEN
			_state := eAxisREFMotionState.MovingAbsolute;
		END_IF
		
	eAxisREFMotionState.MovingAbsolute: //
		IF _status.inPosition AND NOT _status.moving OR currentLimitReached THEN
			targetReached := TRUE;
			_state := eAxisREFMotionState.Idle;
		END_IF
														
	eAxisREFMotionState.Halt: // Stop any active sequence
		_commands.StopNormal := TRUE;
		IF _commands.commandSuccessful THEN
			_state := eAxisREFMotionState.Idle;
		END_IF
		
END_CASE















