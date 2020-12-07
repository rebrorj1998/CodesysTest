(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE EZFEED_STATES :
(
	Idle := 0,
	IndexingFlightMode := 10,
	IndexingPartsMode := 11,
	IndexDwell := 12,
	WaitForBaggerCycleComplete := 13,
	PartsStarved := 20,
	Fault := 99
);
END_TYPE
