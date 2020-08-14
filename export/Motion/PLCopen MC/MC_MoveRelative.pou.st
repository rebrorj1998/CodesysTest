(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveRelative EXTENDS MC_Base
VAR_INPUT
	Distance : REAL;		// Relative distance for the motion (in technical units [u])
	Velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	Acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	Deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
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

ExecuteOSR(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.MoveRel := FALSE;
	Axis.AxisState := AXIS_STATE.AS_ErrorStop;
END_IF


CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start absolute move 
			IF ExecuteOSR.Q THEN
				IF NOT Axis.Error AND Axis.PowerState THEN
					SetBusy();
					Axis.AxisState := AXIS_STATE.AS_DiscreteMotion;
					Axis.TargetPosDist := Distance;
					Axis.ProfileVelocity := Velocity;
					Axis.ProfileAcceleration := Acceleration;
					Axis.ProfileDeceleration := Deceleration;
					Axis.ProfileCurrentLimit := Axis.DefaultCurrent;
					Axis.MoveRel := TRUE;
					MC_State := 1;
					ErrorID := MC_ERROR.NO_ERROR;
				ELSE
					Error := TRUE;
					ErrorID := MC_ERROR.AXIS_NOT_READY;
				END_IF
			END_IF
	
	1:		// Wait for target reached.  Once stopped go back to idle
			IF Axis.TargetReached THEN
				Axis.MoveRel := FALSE;
				Axis.AxisState := AXIS_STATE.AS_Standstill;
				SetDone();
				MC_State := 0;
			ELSIF Axis.AxisState <> AXIS_STATE.AS_DiscreteMotion OR CommandAborted OR NOT Execute THEN
				Axis.MoveRel := FALSE;
				SetAborted();
				MC_State := 0;
			END_IF
END_CASE
