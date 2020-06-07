(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eMotorizedIBDStates :
(
	Idle := 0,
	MoveIn := 10,
	MovingIn := 11, 
	MovedIn := 12,
	MoveOut := 20,
	MovingOut := 21, 
	MovedOut := 22,
	Home := 30,
	Homing := 31, 
	Faulting := 98,
	Faulted := 99,
	Reset := 100, 
	Resetting := 101
);
END_TYPE
