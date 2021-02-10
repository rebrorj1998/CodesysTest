(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eKeyenceLN20_States :
(
	Idle := 0,
	WaitForStatus := 2,
	SetStatus := 3,
	WaitForReadClear := 4,
	Reset := 100
);
END_TYPE
