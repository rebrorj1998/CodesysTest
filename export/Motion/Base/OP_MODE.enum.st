(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE OP_MODE :
(
	OP_UNKNOWN := 0, // The Operating Mode is Unknown
	OP_HOMING := 1, // Homing Mode
	OP_VELOCITY := 2, // Velocity Mode
	OP_POSITION := 3 // Position Mode
);
END_TYPE
