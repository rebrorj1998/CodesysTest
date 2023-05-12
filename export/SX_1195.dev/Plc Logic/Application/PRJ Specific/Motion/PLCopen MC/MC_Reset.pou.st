(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL MC_Reset EXTENDS MC_Base
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_Reset
//	Description: Forces the transition from the state ErrorStop to Standstill or PowerOff by resetting all internal axis-related errors.
//				 If the axis is not in state ErrorStop, the function block signals the error R_NO_ERROR_TO_RESET.
//	Created by: Ben Hess
//	Created Date: May 14th, 2019

//
_executeOSR(CLK := execute);

//
IF _engineState <> eMCEngineState.Idle AND axis.error THEN
	//_moveState := eMCMoveState.Error;
	//_engineState := eMCEngineState.Idle;
	errorID := eMCError.AXIS_ERROR_DURING_COMMAND;
END_IF

//
CASE _engineState OF
	eMCEngineState.Idle:		
		// Idle State.  If execute rising edge then start halt 
		IF _executeOSR.Q THEN
			_moveState := eMCMoveState.Busy;
			_engineState := eMCEngineState.Execute;
			errorID := eMCError.NO_ERROR;
		END_IF
		
	eMCEngineState.Execute:
		axis.ackError := TRUE;
		_engineState := eMCEngineState.Executing;
		
	eMCEngineState.Executing:
		
		IF NOT axis.error THEN
			axis.ackError := FALSE;
			_engineState := eMCEngineState.Executed;
		END_IF
		
	eMCEngineState.Executed:
		axis.axisState := eAxisState.Standstill;
		_moveState := eMCMoveState.Done;
		_engineState := eMCEngineState.Idle;
END_CASE
