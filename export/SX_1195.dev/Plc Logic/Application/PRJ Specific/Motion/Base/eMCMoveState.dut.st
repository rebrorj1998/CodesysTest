(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eMCMoveState :
(
	Done := 0,
	Busy := 1,
	Clear := 2,
	Error := 3,
	Aborted := 4
);
END_TYPE
