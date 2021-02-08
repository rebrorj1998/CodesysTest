(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE PRINT_AND_APPLY_STATES :
(
	Idle := 0,
	WaitForLabel := 10,
	WaitForLOTAR := 11,
	ReadyToApply := 12,
	Applying := 13, 
	Fault := 99
);
END_TYPE
