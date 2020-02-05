(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE DEVICE_MODES :
(
	Manual := 0,	// Control only from service
	Auto := 1,		// Control only from main Bagger Program
	SemiAuto := 2	// Independent control (like as a test fixture)
);
END_TYPE
