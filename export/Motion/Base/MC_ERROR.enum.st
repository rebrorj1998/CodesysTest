(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE MC_ERROR :
(
	NO_ERROR := 0,
	DRIVE_COMM_FAIL := 1,
	DRIVE_FAULTED := 2,
	AXIS_NOT_READY := 3,
	AXIS_ERROR_DURING_COMMAND := 4,
	R_NO_ERROR_TO_RESET := 5
);
END_TYPE
