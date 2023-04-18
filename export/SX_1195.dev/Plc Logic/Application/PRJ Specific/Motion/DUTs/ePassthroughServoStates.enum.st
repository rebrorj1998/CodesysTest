(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE ePassthroughServoStates :
(
	Idle := 0,
	HomingRequired := 1,
	StartHoming := 10,
	Homing := 11,
	HomeComplete := 12,
	MovePassthroughOut := 20,
	MovingPassthroughOut := 21,
	PassthroughMovedOut := 22,
	MovePassthroughIn := 30,
	MovingPassthroughIn := 31,
	PassthroughMovedIn := 32,
	Ready := 40,
	Fault := 99
);
END_TYPE
