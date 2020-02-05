(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE FILLER_STATES :
(
	Idle := 0,
	CycleBaggerToActiveFiller := 10,
	WaitingForFiller := 11,
	Dropping := 13,
	BaggerCycling := 14,
	Fault := 99
);
END_TYPE
