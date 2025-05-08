(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE PACKAGE_TRACKING_STATE :
(
	Idle := 0,
	ScanSection := 1,
	ExitSection := 2,
	TrunkSection := 3
);
END_TYPE
