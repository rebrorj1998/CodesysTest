

FUNCTION_BLOCK PickAndPlaceFB EXTENDS BaseComponentFB
VAR_INPUT
	XAxisMotor : IPositionableMotor;	// X Axis Motor
	YAxisMotor : IPositionableMotor;	// Y Axis Motor
	ZAxisMotor : IPositionableMotor;	// Z Axis Motor
END_VAR
VAR_OUTPUT
	state : VACUUM_PICKER_STATES;	 //State indication
END_VAR
VAR
	
	accel : INT := 2000;
	decel : INT := 2000;
	velo : INT := 2000;
	zVelo : INT := 12000;
END_VAR

//	Function Block: PickAndPlaceFB
//	Description: This provides the methods and state machine to operate the Vacuum Head pick and place machine
//	
//	Created by: Ben Hess
//	Created Date: Friday, June 1, 2018

// Run the base FB
SUPER^();

// Set up the 3 motors.

// X Axis moves out and in relative to the machine. Out is 0in, max in is 7.5in.


IF enableONS.Q THEN
    IF _mode = DEVICE_MODES.Manual THEN 
        state := VACUUM_PICKER_STATES.Manual;
    ELSE
        state := VACUUM_PICKER_STATES.Ready;
    END_IF
END_IF

IF NOT enable THEN
    state := VACUUM_PICKER_STATES.Idle;
END_IF

_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = VACUUM_PICKER_STATES.Fault);


CASE state OF
	VACUUM_PICKER_STATES.Idle :
	VACUUM_PICKER_STATES.Home :								// Move everything to home position
															XAxisMotor.MoveToPosition(6, accel,decel,velo);
															YAxisMotor.MoveToPosition(15, accel,decel,velo);
															ZAxisMotor.MoveToPosition(1, accel,decel,zVelo);
															state := VACUUM_PICKER_STATES.Homing;
															
	VACUUM_PICKER_STATES.Homing :							// Move on if all motors report ready
															IF XAxisMotor.CurrentPosition = 6
																AND YAxisMotor.CurrentPosition = 15
																AND ZAxisMotor.CurrentPosition = 1 THEN
																	state := VACUUM_PICKER_STATES.Homed;
															END_IF
															
	VACUUM_PICKER_STATES.Homed :							// 
															state :=VACUUM_PICKER_STATES.XAxisMoveIn;
															
	VACUUM_PICKER_STATES.XAxisMoveIn :						// Move XAxis in 
															XAxisMotor.MoveToPosition(0,accel,decel,velo);
															state := VACUUM_PICKER_STATES.XAxisMovingIn;
															
	VACUUM_PICKER_STATES.XAxisMovingIn :					// 
															IF XAxisMotor.CurrentPosition = 0 THEN
																state := VACUUM_PICKER_STATES.XaxisMovedIn;
															END_IF
															
	VACUUM_PICKER_STATES.XaxisMovedIn :						// 
															state := VACUUM_PICKER_STATES.VacuumTurnOn;
															
	VACUUM_PICKER_STATES.VacuumTurnOn :						// 
															state := VACUUM_PICKER_STATES.VacuumHeadDown;
															
	VACUUM_PICKER_STATES.VacuumHeadDown :					// 
															ZAxisMotor.MoveToPosition(150,accel,decel,zVelo);
															state := VACUUM_PICKER_STATES.YAxisMoveDown;
															
	VACUUM_PICKER_STATES.YAxisMoveDown :					// 
															YAxisMotor.MoveToPosition(1,accel,decel,velo);
															state := VACUUM_PICKER_STATES.VacuumHeadAndYAxisMovingDown;
															
	VACUUM_PICKER_STATES.VacuumHeadAndYAxisMovingDown :		// 
															IF YAxisMotor.CurrentPosition = 1
																AND ZAxisMotor.CurrentPosition = 150 THEN
																state := VACUUM_PICKER_STATES.VacuumHeadAndYAxisMovedDown;  
															END_IF	
															
	VACUUM_PICKER_STATES.VacuumHeadAndYAxisMovedDown :		// 
															state := VACUUM_PICKER_STATES.VacuumTurnOff;
															
	VACUUM_PICKER_STATES.VacuumTurnOff :					// 
															state := VACUUM_PICKER_STATES.ConveyorTurnOn;
															
	VACUUM_PICKER_STATES.ConveyorTurnOn :					// 
															state := VACUUM_PICKER_STATES.ConveyorMoving;
															
	VACUUM_PICKER_STATES.ConveyorMoving :					// 
															state := VACUUM_PICKER_STATES.ConveyorDone;
															
	VACUUM_PICKER_STATES.ConveyorDone :						// 
															state := VACUUM_PICKER_STATES.Ready;
															
	VACUUM_PICKER_STATES.Fault :							// 
																													
	
	VACUUM_PICKER_STATES.Ready :							IF semiAutoModeSelected THEN
																state := VACUUM_PICKER_STATES.Home;
															END_IF
	VACUUM_PICKER_STATES.Manual :
END_CASE