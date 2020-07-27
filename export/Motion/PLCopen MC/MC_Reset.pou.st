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

ExecuteOSR(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.AckError := FALSE;
END_IF


CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start halt 
			IF ExecuteOSR.Q THEN
				//IF Axis.Error THEN
					SetBusy();
					Axis.AckError := TRUE;
					MC_State := 1;
				//ELSE
				//	Error := TRUE;
				//	ErrorID := MC_ERROR.R_NO_ERROR_TO_RESET;
				//END_IF
			END_IF
	
	1:		// Clearing error.  Once stopped go back to idle
			IF NOT Axis.Error THEN
				Axis.AckError := FALSE;
				Axis.AxisState := AXIS_STATE.AS_Standstill;
				SetDone();
				MC_State := 0;
			END_IF
END_CASE
