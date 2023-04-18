(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL MC_Halt EXTENDS MC_Base
VAR_INPUT
	deceleration : REAL; 	// Value of the deceleration (decreasing energy of the motor) [u/s²]
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_Halt
//	Description: Commands a controlled motion stop. The axis is moved to the state DiscreteMotion, until the velocity is zero. 
//				 When the output Done is set, the state is transferred to Standstill.
//	Created by: Ben Hess
//	Created Date: May 3rd, 2019

//
_executeOSR(CLK := execute);

//
IF _engineState <> eMCEngineState.Idle AND axis.error THEN
	_moveState := eMCMoveState.Error;
	_engineState := eMCEngineState.Idle;
	axis.axisState := eAxisState.Standstill;
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
		axis.axisState := eAxisState.Halting;
		axis.quickStopDeceleration := deceleration;
		axis.halt := TRUE;
		_engineState := eMCEngineState.Executing;
			
	eMCEngineState.Executing:
		axis.halt := FALSE;
		IF axis.actVel = 0 THEN
			_engineState := eMCEngineState.Executed;
		END_IF
		
	eMCEngineState.Executed:
		axis.axisState := eAxisState.Standstill;
		_moveState := eMCMoveState.Done;
		_engineState := eMCEngineState.Idle;
			
END_CASE


 