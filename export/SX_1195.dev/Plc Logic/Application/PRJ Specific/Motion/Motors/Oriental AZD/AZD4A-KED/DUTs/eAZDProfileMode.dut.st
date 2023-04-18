(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAZDProfileMode :
(
	PP := 1,  // Profile position mode
	PV := 3,  // Profile Velocity mode 
	HM := 6,  // Homing mode
	CSP := 8, // Cyclic synchronous position mode
	CSV := 9  // Cyclic synchronous velocity mode
) SINT;
END_TYPE
