(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL MC_Home EXTENDS MC_Base
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_Home
//	Description: Commands the axis to perform the «search home» sequence. The details of this sequence are manufacturer specific and can be set by the axis’ parameters. 
//				 After completion, the axis state is Standstill if it was Standstill when started.
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
		// Idle State.  If execute rising edge then start halt 
		IF _executeOSR.Q THEN
			IF NOT axis.error AND axis.operational THEN
				_moveState := eMCMoveState.Busy;
				_engineState := eMCEngineState.Execute;
				axis.modeOfOperation := eAZDProfileMode.HM;
				errorID := eMCError.NO_ERROR;
			ELSE
				_moveState := eMCMoveState.Error;
				errorID := eMCError.AXIS_NOT_READY;
			END_IF
		END_IF
	
	eMCEngineState.Execute:
		axis.axisState := eAxisState.Homing;
		axis.startHoming := TRUE;
		_engineState := eMCEngineState.Executing;
	
	eMCEngineState.Executing:
		axis.startHoming := FALSE;
		IF axis.isHomed THEN
			_engineState := eMCEngineState.Executed;
		END_IF
	
	eMCEngineState.Executed:
		_moveState := eMCMoveState.Done;
		_engineState := eMCEngineState.Idle;
		axis.axisState := eAxisState.Standstill;
			
END_CASE
