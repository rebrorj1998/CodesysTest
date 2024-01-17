(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveRelative EXTENDS MC_Base
VAR_INPUT
	distance : REAL;		// Relative distance for the motion (in technical units [u])
	velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
	currentLimit : REAL;
	torqueModeOnCompletion : BOOL := FALSE;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_MoveRelative
//	Description: Commands a controlled motion of a specified distance relative to the position at the time of the execution.
//				 The motion completes with velocity zero.
//				 After completion, the axis state is Standstill.
//	Created by: Ben Hess
//	Created Date: May 6th, 2019

IF _engineState <> eMCEngineState.Idle AND axis.error THEN
	_moveState := eMCMoveState.Error;
	_engineState := eMCEngineState.Idle;
	axis.axisState := eAxisState.ErrorStop;
	errorID := eMCError.AXIS_ERROR_DURING_COMMAND;
	Axis.moveRel := FALSE;
END_IF

_executeOSR(CLK := execute);
CASE _engineState OF
	eMCEngineState.Idle:		
		// Idle State. If execute rising edge then start absolute move 
		IF _executeOSR.Q THEN
			IF NOT axis.error AND axis.operational THEN
				_moveState := eMCMoveState.Busy;
				_engineState := eMCEngineState.Execute;
				errorID := eMCError.NO_ERROR;
			ELSE
				_moveState := eMCMoveState.Error;
				errorID := eMCError.AXIS_NOT_READY;
			END_IF
		END_IF
			
	eMCEngineState.Execute:
		axis.axisState := eAxisState.DiscreteMotion;
		axis.targetPosDist := distance;
		axis.profileVelocity := velocity;
		axis.profileAcceleration := acceleration;
		axis.profileDeceleration := deceleration;
		axis.profileCurrentLimit := currentLimit;
		axis.modeOfOperation := eAZDProfileMode.PP;
		axis.finalMove := torqueModeOnCompletion;
		axis.moveRel := TRUE;
		_engineState := eMCEngineState.Executing;
		
	eMCEngineState.Executing:
		// Wait for target reached.  Once stopped go back to idle
			axis.moveRel := FALSE;		
		IF axis.targetReached THEN

			_engineState := eMCEngineState.Executed;
		ELSIF axis.axisState <> eAxisState.DiscreteMotion OR Aborted OR NOT execute THEN

			_moveState := eMCMoveState.Aborted;
			_engineState := eMCEngineState.Idle;
		END_IF
		
	eMCEngineState.Executed:
		_moveState := eMCMoveState.Done;
		_engineState := eMCEngineState.Idle;
		axis.axisState := eAxisState.Standstill;
	
END_CASE
