(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAxisREFMotionState :
(
	Idle := 0,
	MoveAbsolute := 1,
	MovingAbsolute := 2,
	MoveAbsoluteTorque := 3,
	MovingAbsoluteTorque := 4,
	MoveRelative := 5,
	MovingRelative := 6, 
	MoveRelativeFinal := 7,
	Home := 8,
	Homing := 9,
	Halt := 10,
	Halting := 11,
	Jog := 12,
	Cleanup := 13
);
END_TYPE
