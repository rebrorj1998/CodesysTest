(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE VACUUM_PICKER_STATES :
(
	Idle := 0,
	Home := 1, 
	Homing := 2, 
	Homed := 3,
	XAxisMoveIn := 10,
	XAxisMovingIn := 11, 
	XaxisMovedIn := 12,
	VacuumTurnOn := 20,
	VacuumHeadDown := 30,
	YAxisMoveDown := 31,
	VacuumHeadAndYAxisMovingDown := 32,
	VacuumHeadAndYAxisMovedDown := 33,
	VacuumTurnOff := 40,
	ConveyorTurnOn := 50,
	ConveyorMoving := 51,
	ConveyorDone := 52,

	Fault := 99,
	Ready := 100,
	Manual := 101
);
END_TYPE