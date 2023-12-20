(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE eDualMotorPressureBar_AsyncStates :
(
	Idle := 0,
	Jogging := 10,
	Home := 20,
	Homing := 30,
	CloseToFaceplate := 40,
	ClosingToFaceplate := 50,
	ClosedToFaceplate := 60,
	Open := 70,
	Opening := 80,
	Opened := 90,
	Clamp := 100,
	Clamping := 110,
	Clamped := 120,
	Release := 130,
	Releasing := 140,
	Fault := 150,
	Faulting := 160,
	Faulted := 170,
	MovingPassthrough := 180,
	Reset := 190,
	Resetting := 200,
	ResetDone := 201,
	ResetEncoder := 205,
	Halting := 210,
	Cleanup := 220,
	HaltDelay := 230
);
END_TYPE
