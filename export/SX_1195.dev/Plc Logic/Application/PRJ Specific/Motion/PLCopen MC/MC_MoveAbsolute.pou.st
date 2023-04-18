(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveAbsolute EXTENDS MC_Base
VAR_INPUT
	position : REAL;		// Commanded position for the motion (may be negative) (in technical units [u])
	velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
	currentLimit : REAL;	// Current limit in %
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_MoveAbsolute
//	Description: Commands a controlled motion to a specified absolute position.
//				 After completion, the axis state is Standstill.
//	Created by: Ben Hess
//	Created Date: May 3rd, 2019

//
_executeOSR(CLK := execute);

//
IF _engineState <> eMCEngineState.Idle AND axis.error THEN
	_moveState := eMCMoveState.Error;
	_engineState := eMCEngineState.Idle;
	errorID := eMCError.AXIS_ERROR_DURING_COMMAND;
END_IF

//
CASE _engineState OF
	eMCEngineState.Idle:		
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
		axis.targetPosDist := Position;
		axis.profileVelocity := Velocity;
		axis.profileAcceleration := Acceleration;
		axis.profileDeceleration := Deceleration;
		axis.profileCurrentLimit := currentLimit;
		axis.modeOfOperation := eAZDProfileMode.PP;
		axis.moveAbs := TRUE;
		axis.push := FALSE;
		_engineState := eMCEngineState.Executing;
		
	eMCEngineState.Executing:
		// Wait for target reached.  Once stopped go back to idle
		axis.moveAbs := FALSE;
		IF axis.targetReached  THEN
			_engineState := eMCEngineState.Executed;
		ELSIF axis.axisState <> eAxisState.DiscreteMotion OR aborted THEN
			_moveState := eMCMoveState.Aborted;
			_engineState := eMCEngineState.Idle;
		END_IF
		
	eMCEngineState.Executed:
		_moveState := eMCMoveState.Done;
		_engineState := eMCEngineState.Idle;
		axis.axisState := eAxisState.Standstill;
		
END_CASE
