(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE MotorizedPbarStatesRubberBand :
(
	Idle := 0,
	Homing := 9,
	Initialize := 10,
	Initializing := 11,
	Initialized := 12,
	PrepareToSetPositionLimit := 13,
	PreparingToSetPositionLimit := 14,
	PreparedSettingPositionLimit := 15,
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
	StartRubberBanding := 50,
	ResettingEncoder := 97,
	Faulting := 98,
	Faulted := 99
);
END_TYPE
