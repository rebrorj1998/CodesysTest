(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eMCEngineState :
(
	Idle := 0,
	Execute := 1,
	Executing := 2,
	Executed := 3
);
END_TYPE
