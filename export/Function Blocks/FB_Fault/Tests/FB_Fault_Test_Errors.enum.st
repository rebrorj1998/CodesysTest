(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE FB_Fault_Test_Errors :
(
	No_Error := 0,
	Fault_Not_Reset,
	Fault_Active,
	Fault_Not_Triggered
);
END_TYPE
