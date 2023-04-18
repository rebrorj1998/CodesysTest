(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveVelocity EXTENDS MC_Base
VAR_INPUT
	execute : BOOL; 		// Rising edge: The halt is started 
	velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
END_VAR
VAR_OUTPUT
	inVelocity : BOOL;		// Value of the commanded velocity (may be negative) (not necessarily reached) [u/s]
	errorID : eMCError;		// Error number
END_VAR
VAR
	_velocityONS : Standard.F_TRIG;
END_VAR
VAR_IN_OUT
	axis : Axis_REF;		// Reference to the axis 
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_MoveVelocity
//	Description: Commands a never ending controlled motion with a specified velocity.
//				 To stop the motion, the motion has to be interrupted by another motion command.
//				 The output InVelocity is reset when the block is aborted by another block.
//	Created by: Ben Hess
//	Created Date: May 6th, 2019

//
_velocityONS(CLK := axis.inVelocity);

//
_executeOSR(CLK := execute);

//
IF _engineState <> eMCEngineState.Idle AND axis.error THEN
	_moveState := eMCMoveState.Error;
	_engineState := eMCEngineState.Idle;
	axis.axisState := eAxisState.ErrorStop;
	errorID := eMCError.AXIS_ERROR_DURING_COMMAND;
END_IF

//
CASE _engineState OF
	eMCEngineState.Idle:		
		// Idle State.  If execute rising edge then start absolute move 
		IF _executeOSR.Q THEN
			IF NOT axis.Error AND axis.operational THEN
				_moveState := eMCMoveState.Busy;
				_engineState := eMCEngineState.Executing;
				errorID := eMCError.NO_ERROR;
			ELSE
				_moveState := eMCMoveState.Error;
				errorID := eMCError.AXIS_NOT_READY;
			END_IF
		END_IF
		
	eMCEngineState.Execute:
		//
		inVelocity := TRUE;
		axis.axisState := eAxisState.ContinuousMotion;
		axis.profileVelocity := velocity;
		axis.profileAcceleration := acceleration;
		axis.profileDeceleration := deceleration;
		axis.modeOfOperation := eAZDProfileMode.PV;
		axis.moveVel := TRUE;
		_engineState := eMCEngineState.Executing;
		
	eMCEngineState.Executing:
		axis.moveVel := FALSE;
		IF _velocityONS.Q THEN
			_engineState := eMCEngineState.Executed;
		END_IF
		
	eMCEngineState.Executed:
		InVelocity := FALSE;
		_engineState := eMCEngineState.Idle;
	
END_CASE
