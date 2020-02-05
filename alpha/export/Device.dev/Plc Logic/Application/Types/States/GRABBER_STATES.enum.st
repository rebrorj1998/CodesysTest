(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE GRABBER_STATES :
(
	Idle := 0,
	OpenGrippers := 10,
	MoveGrippersOut := 11,
	MovingGrippersOut := 12,
	GrippersMovedOut :=13,
	MoveGantryUp := 20,
	MovingGantryUp := 21,
	GantryMovedUp := 22,
	MoveGrippersIn := 30,
	MovingGrippersIn := 31,
	GrippersMovedIn := 32,
	Ready := 40,
	GrabBag := 50,
	MoveGantryDown := 60,
	MovingGantryDown := 61,
	GantryMovedDown := 62,
	ReleaseBag := 70,
	Fault := 99
);
END_TYPE
