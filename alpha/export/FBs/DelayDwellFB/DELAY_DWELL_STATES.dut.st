(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE DELAY_DWELL_STATES :
(
	Idle := 0,
	Delay := 1,
	Dwell := 2,
	ResettingDwell := 10,
	ManualOn := 20,
	ManualOff := 21
);
END_TYPE
