(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE CycleFirstBagOutOfCageStates :
(
	Idle := 0,
	StartCycle := 10, 
	WaitForBagToReachEndOfIncline := 20,
	PauseForOperatorRemoval := 30
);
END_TYPE
