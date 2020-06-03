(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eDualMotorPBarStates :
(
	Idle := 0,
	Jogging := 10,
	CloseJaw := 20,
	ClosingJaw := 21,
	ClosedJaw := 22,
	OpenJaw := 40,
	OpeningJaw := 41,
	OpenedJaw := 42,
	HomeJaw := 60,
	HomingJaw := 61,
	HomedJaw := 62,
	Faulting := 98,
	Faulted := 99,
	Reset := 100,
	Resetting := 101
);
END_TYPE
