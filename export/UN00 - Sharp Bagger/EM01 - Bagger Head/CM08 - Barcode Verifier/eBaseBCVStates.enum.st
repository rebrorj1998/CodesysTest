(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE eBaseBCVStates :
(
	Idle := 0,
	WaitForOffset := 10,
	TriggerReader := 11,
	WaitingForResult := 12,
	Resetting := 13
);
END_TYPE
