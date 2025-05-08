(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE PASSIVE_FAULT_TRIGGERS :
(
	AfterTime := 0,
	AfterTamp := 1,
	AfterSeal := 2,
	onTrunk := 3,
	AfterScanned := 4
);
END_TYPE
