(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_MoveVelocity
VAR_INPUT
	Execute : BOOL; 		// Rising edge: The halt is started 
	Velocity : REAL;		// Value of the maximum velocity (always positive) (not necessarily reached) [u/s]
	Acceleration : REAL;	// Value of the acceleration (always positive) (increasing energy of the motor) [u/s²]
	Deceleration : REAL;	// Value of the deceleration (always positive) (decreasing energy of the motor) [u/s²]
END_VAR
VAR_OUTPUT
	InVelocity : BOOL;		// Value of the commanded velocity (may be negative) (not necessarily reached) [u/s]
	Busy : BOOL;			// TRUE as long as MC_Halt is operating, reset when velocity is zero
	CommandAborted : BOOL;	// Commanded motion was interrupted by any motion FB acting on the same axis
	Error : BOOL;			// Signals that an error has occured
	ErrorID : MC_ERROR;		// Error number
END_VAR
VAR
	ExecuteOSR : Standard.R_TRIG;
	MC_State : INT;
END_VAR
VAR_IN_OUT
	Axis : Axis_REF;		// Reference to the axis 
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_MoveVelocity
//	Description: Commands a never ending controlled motion with a specified velocity.
//				 To stop the motion, the motion has to be interrupted by another motion command.
//				 The output InVelocity is reset when the block is aborted by another block.
//	Created by: Ben Hess
//	Created Date: May 6th, 2019

ExecuteOSR(CLK := Execute);

IF MC_State <> 0 AND Axis.Error THEN
	SetError();
	ErrorID := MC_ERROR.AXIS_ERROR_DURING_COMMAND;
	MC_State := 0;
	Axis.MoveVelo := FALSE;
	Axis.AxisState := AXIS_STATE.AS_ErrorStop;
END_IF


CASE MC_State OF
	0:		// Idle State.  If execute rising edge then start absolute move 
			IF ExecuteOSR.Q THEN
				IF NOT Axis.Error AND Axis.PowerState THEN
					SetBusy();
					Axis.AxisState := AXIS_STATE.AS_ContinuousMotion;
					Axis.ProfileVelocity := Velocity;
					Axis.ProfileAcceleration := Acceleration;
					Axis.ProfileDeceleration := Deceleration;
					Axis.ProfileCurrentLimit := Axis.DefaultCurrent;
					Axis.MoveVelo := TRUE;
					MC_State := 1;
				ELSE
					Error := TRUE;
					ErrorID := MC_ERROR.AXIS_NOT_READY;
				END_IF
			END_IF
	
	1:		// Wait for target reached.
			IF Axis.InVelocity THEN
				Axis.MoveVelo := FALSE;
				SetInVelo();
				MC_State := 2;
			END_IF
	
	2:		// If another MC turns off velocity mode then go back to idle
			IF NOT Axis.InVelocity THEN
				InVelocity := FALSE;
				MC_State := 0;
			END_IF
END_CASE
