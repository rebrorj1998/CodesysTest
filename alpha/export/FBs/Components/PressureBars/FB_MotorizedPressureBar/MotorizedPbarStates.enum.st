(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE MotorizedPbarStates :
(
	Idle := 0,
	Homing := 9,
	Initialize := 10,
	Initializing := 11,
	Initialized := 12,
	MoveJawOut := 20,
	MovingJawOut := 21,
	MovedJawOut := 22,
	MoveJawClear := 23,
	MoveJawIn := 30,
	MovingJawIn := 31,
	MovedJawIn := 32,
	StartClamping := 40,
	StartedClamping := 41,
	Clamping := 42, 
	ReleaseClamp := 43, 
	ReleasingClamp := 44,
	Faulting := 98,
	Faulted := 99
);
END_TYPE
