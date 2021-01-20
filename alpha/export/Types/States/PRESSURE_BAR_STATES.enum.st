(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE PRESSURE_BAR_STATES :
(
	Idle := 0,
	OpenJaw := 10,
	OpeningJaw := 11,
	JawOpened := 12,
	CloseJaw := 20,
	ClosingJaw := 21,
	JawClosed := 22,
	Sealing := 30,
	Manual := 40,
	Homing := 41,
	Fault := 99
);
END_TYPE
