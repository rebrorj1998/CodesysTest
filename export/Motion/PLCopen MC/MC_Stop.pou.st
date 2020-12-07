(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL MC_Stop EXTENDS MC_Base
VAR_INPUT
	Deceleration : REAL; 	// Value of the deceleration (decreasing energy of the motor) [u/s²]
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_Stop
//	Description: 	Executes a (blocking) stop on the axis.
//					As long as the Execute input is set or the stop is not finished, no other motion command is possible on the axis, 
//					and the axis state is Stopping. After both the stop is finished and Execute is reset, the axis status is set to Standstill.

//	Created by: Ben Hess
//	Created Date: May 3rd, 2019

ExecuteOSR(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.Halt := FALSE;
	Axis.AxisState := AXIS_STATE.AS_Standstill;
END_IF

CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start halt 
			IF ExecuteOSR.Q THEN
				IF NOT Axis.Error AND Axis.PowerState THEN
					SetBusy();
					Axis.AxisState := AXIS_STATE.AS_DiscreteMotion;
					Axis.QuickStopDeceleration := Deceleration;
					Axis.Halt := TRUE;
					MC_State := 1;
				ELSE
					Error := TRUE;
					ErrorID := MC_ERROR.AXIS_NOT_READY;
				END_IF
				
			END_IF
	
	1:		// Stopping.  Once stopped go back to idle
			IF Axis.ActVelocity = 0 THEN
				Axis.Halt := FALSE;
				Axis.AxisState := AXIS_STATE.AS_Standstill;
				SetDone();
				MC_State := 0;
			END_IF
			
	99: 		// Error
END_CASE


 