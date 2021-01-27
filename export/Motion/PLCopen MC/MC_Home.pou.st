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

ExecuteOSR(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.StartHoming := FALSE;
	Axis.AxisState := AXIS_STATE.AS_Standstill;
END_IF


CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start halt 
			IF ExecuteOSR.Q THEN
				IF NOT Axis.Error AND Axis.PowerState THEN
					SetBusy();
					Axis.AxisState := AXIS_STATE.AS_Homing;
					Axis.StartHoming := TRUE;
					MC_State := 1;
				ELSE
					Error := TRUE;
					ErrorID := MC_ERROR.AXIS_NOT_READY;
				END_IF
				
			END_IF
	
	1:		// Stopping.  Once stopped go back to idle
			IF Axis.HomingDone THEN
				Axis.StartHoming := FALSE;
				Axis.AxisState := AXIS_STATE.AS_Standstill;
				SetDone();
				MC_State := 0;
			END_IF
END_CASE
