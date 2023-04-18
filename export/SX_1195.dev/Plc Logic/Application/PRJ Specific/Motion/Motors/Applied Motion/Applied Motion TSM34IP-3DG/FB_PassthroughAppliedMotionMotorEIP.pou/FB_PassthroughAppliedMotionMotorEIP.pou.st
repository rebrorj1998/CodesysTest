(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PassthroughAppliedMotionMotorEIP EXTENDS FB_BaseAppliedMotionMotorEIP
VAR
	homingSequenceActive : BOOL;
	homeDelayTimer : Standard.TON := (PT := T#200MS);
	homeState : eAppliedMotionHomingStates;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_SlaveAppliedMotionMotorEIP()
//	Description: A PLCOpen Motion compliant library for a Oriental AZ Series drive/motor			 
//	Created by: Evan Ische
//	Created Date: Tuesday, October 13th 2020

// Outputs for Motion Lib
operational := powerOn;
EnableState := driveEnable;

// Exit if drive isn't enabled.
IF NOT driveEnable THEN
	RETURN;
END_IF

SUPER^();

//
homeDelayTimer();

// On rising edge of the reset, nil out the state engine
IF _resetONS.OSR THEN
	_state := eAxisREFMotionState.Cleanup;
END_IF

//
homingSequenceActive := dataFromDrive[11].0;

CASE _state OF
	eAxisREFMotionState.Idle: // 	
		targetReached := FALSE;
		IF _moveAbsONS.OSR THEN
			_state := eAxisREFMotionState.MoveAbsolute; // Start internal state sequence
		ELSIF _homeONS.OSR THEN
			_state := eAxisREFMotionState.Homing;
		END_IF
		SUPER^.ClearMotorCommand();
		
		homeState := eAppliedMotionHomingStates.Idle;
		eAxisREFMotionState.Homing: //
			CASE homeState OF
				eAppliedMotionHomingStates.Idle:
					profileVelocity := homingParameters.velocity;
					profileAcceleration := homingParameters.acceleration;
					profileDeceleration := homingParameters.deceleration;
					homeState := eAppliedMotionHomingStates.StartHoming;
															
				eAppliedMotionHomingStates.StartHoming:
					SUPER^.ExecuteStoredProgram(MotorData.HOMING_SEQUENCE_PROGRAM);
					IF _commands.commandSuccessful THEN
						homeState := eAppliedMotionHomingStates.Homing;
					END_IF
										
				eAppliedMotionHomingStates.Homing:				
					homeDelayTimer.IN := TRUE;
					IF homeDelayTimer.Q THEN
						IF NOT homingSequenceActive THEN	
							profileCurrentLimit := defaultCurrent;
 							homeState := eAppliedMotionHomingStates.SetLimits;
 							homeDelayTimer.IN := FALSE;
						END_IF
					END_IF 
															
				eAppliedMotionHomingStates.SetLimits: 
					SUPER^.ExecuteStoredProgram(MotorData.MOTOR_LIMITS_PROGRAM);
					IF _commands.commandSuccessful THEN
						isHomed := TRUE;
						_state := eAxisREFMotionState.Cleanup;
					END_IF
			END_CASE
			
		eAxisREFMotionState.Jog,		
		eAxisREFMotionState.MoveAbsolute: 
			_commands.FeedToPosition := TRUE;
			IF _commands.commandSuccessful THEN
				_state := eAxisREFMotionState.MovingAbsolute;
			END_IF
		
		eAxisREFMotionState.MovingAbsolute:
			IF _status.inPosition OR NOT _status.moving OR currentLimitReached THEN
				targetReached := TRUE;
				_state := eAxisREFMotionState.Cleanup;
			END_IF
											
		eAxisREFMotionState.Halt: // Stop any active sequence
			_commands.StopNormal := TRUE;
			IF _commands.commandSuccessful THEN
				_state := eAxisREFMotionState.Cleanup;
			END_IF
			
		eAxisREFMotionState.Cleanup:
			homeDelayTimer.IN := FALSE;
			_state := eAxisREFMotionState.Idle;
END_CASE















