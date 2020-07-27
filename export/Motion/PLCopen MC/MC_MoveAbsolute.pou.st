(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveAbsolute EXTENDS MC_Base
VAR_INPUT
	Position : REAL;		// Commanded position for the motion (may be negative) (in technical units [u])
	Velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	Acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	Deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
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

ExecuteOSR(CLK := Execute);
ExecuteOSF(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.MoveAbs := FALSE;
END_IF


CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start absolute move 
			IF ExecuteOSR.Q THEN
				IF NOT Axis.Error AND Axis.PowerState THEN
					SetBusy();
					Axis.AxisState := AXIS_STATE.AS_DiscreteMotion;
					Axis.TargetPosDist := Position;
					Axis.ProfileVelocity := Velocity;
					Axis.ProfileAcceleration := Acceleration;
					Axis.ProfileDeceleration := Deceleration;
					Axis.ProfileCurrentLimit := Axis.DefaultCurrent;
					Axis.MoveAbs := TRUE;
					MC_State := 1;
					ErrorID := MC_ERROR.NO_ERROR;
				ELSE
					SetError();
					ErrorID := MC_ERROR.AXIS_NOT_READY;
				END_IF
			END_IF
	
	1:		// Wait for target reached.  Once stopped go back to idle
			IF Axis.TargetReached THEN
				Axis.MoveAbs := FALSE;
				SetDone();
				MC_State := 0;
			ELSIF Axis.AxisState <> AXIS_STATE.AS_DiscreteMotion OR CommandAborted THEN
				Axis.MoveAbs := FALSE;
				SetAborted();
				MC_State := 0;
			END_IF
END_CASE
