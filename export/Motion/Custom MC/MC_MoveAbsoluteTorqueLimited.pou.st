(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveAbsoluteTorqueLimited EXTENDS MC_Base
VAR_INPUT
	Position : REAL;		// Commanded position for the motion (may be negative) (in technical units [u])
	Velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	Acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	Deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
	CurrentLimit : REAL;	// Maximum current allowed to perform the move [A]
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_MoveAbsoluteTorqueLimited
//	Description: Commands a controlled motion to a specified absolute position with torque limiting.
//				 After completion, the axis state is Standstill.
//				 This FB is an extention of the PLCOpen standard
//	Created by: Ben Hess
//	Created Date: May 3rd, 2019

ExecuteOSR(CLK := Execute);
ExecuteOSF(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.MoveAbsTorque := FALSE;
END_IF


CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start absolute move 
			IF ExecuteOSR.Q THEN
				IF NOT Axis.Error AND Axis.PowerState THEN
					SetBusy();
					Axis.TargetPosDist := Position;
					Axis.ProfileVelocity := Velocity;
					Axis.ProfileAcceleration := Acceleration;
					Axis.ProfileDeceleration := Deceleration;
					Axis.ProfileCurrentLimit := CurrentLimit;
					Axis.MoveAbsTorque := TRUE;
					MC_State := 1;
				ELSE
					SetError();
					ErrorID := MC_ERROR.AXIS_NOT_READY;
				END_IF
			END_IF
	
	1:		// Wait for target reached.  Once stopped go back to idle
			IF Axis.TargetReached THEN
				Axis.MoveAbsTorque := FALSE;
				SetDone();
				MC_State := 0;
			ELSIF Axis.AxisState <> AXIS_STATE.AS_DiscreteMotion THEN
				Axis.MoveAbsTorque := FALSE;
				SetError();
				MC_State := 0;
			END_IF
END_CASE
