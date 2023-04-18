(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MasterAppliedMotionMotorEIP EXTENDS FB_BaseAppliedMotionMotorEIP
VAR_INPUT
END_VAR
VAR
	internalState: eRelativeMoveState;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_MasterAppliedMotionMotorEIP()
//	Description: A PLCOpen Motion compliant library for a Oriental AZ Series drive/motor
//	Created by: Evan Ische
//	Created Date: Tuesday, October 13th 2020

// Outputs for Motion Lib
operational := PowerOn;
EnableState := DriveEnable;

// Exit if drive isn't enabled.
IF NOT DriveEnable THEN
	RETURN;
END_IF

SUPER^();

// On rising edge of the reset, nil out the state engine
IF _resetONS.OSR THEN
	targetReached := FALSE;
	_state := eAxisREFMotionState.Idle;
END_IF

CASE _state OF
	eAxisREFMotionState.Idle:// 	Idle state, wait for command
		targetReached := FALSE;
		IF _moveRelONS.OSR THEN
			_state := eAxisREFMotionState.MoveRelative; // Start internal state sequence
		END_IF
		internalState := eRelativeMoveState.Idle;
		
	eAxisREFMotionState.Jog,	
	eAxisREFMotionState.MoveRelative:
		
		CASE internalState OF
			eRelativeMoveState.Idle:
				// Begin the move sequence
				internalState := eRelativeMoveState.SetOutputOff;
																	
			eRelativeMoveState.SetOutputOff:
				// Turn off torque mode on the slave motor so it followes pulses then move on to the next state		
				THIS^.SetSlaveMotorToEncoderMode(); // Torque Mode Off
				IF _commands.commandSuccessful THEN
					internalState := eRelativeMoveState.MoveMotor;
				END_IF
																		
			eRelativeMoveState.MoveMotor:
				// Clear SCL parameters and then Feed to length using parameters passed in MC				
				ClearMotorCommand(); // Clear CMD and Params
				_commands.FeedToLength := TRUE;
				IF _commands.commandSuccessful THEN
					internalState := eRelativeMoveState.WaitAfterMovingMotor;
				END_IF
																						
			eRelativeMoveState.WaitAfterMovingMotor:
				// If the move is successful and final move is off, Update the state engine to idle state, otherwise continue	
				IF _status.inPosition THEN
					IF finalMove THEN
						internalState := eRelativeMoveState.SetOutputOn;
					ELSE
						targetReached := TRUE;
						_state := eAxisREFMotionState.Idle;
					END_IF
				END_IF
				
			eRelativeMoveState.SetOutputOn:
				//Turn on torque mode on the slave motor 	 
				THIS^.SetSlaveMotorToTorqueMode(); // Torque Mode On
				IF _commands.commandSuccessful THEN
					internalState := eRelativeMoveState.WaitAfterSettingOutputOn;
				END_IF
				
			eRelativeMoveState.WaitAfterSettingOutputOn:
				// Upon completion, Update the state engine to idle state
				targetReached := TRUE;
				_state := eAxisREFMotionState.Idle;
		END_CASE									
																					
	eAxisREFMotionState.Halt:
		// Stop any active sequence
		_commands.StopNormal := TRUE;
		IF _commands.commandSuccessful THEN
			_state := eAxisREFMotionState.Idle;
		END_IF

END_CASE