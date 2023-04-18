(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAZDPowerupState :
(
	Idle := 0,
	Shutdown := 1,
	SwitchOn := 2,
	SwitchOnEnableOp := 3,
	Operational := 4
);
END_TYPE
