(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
TYPE MURR_SYSTEM_STATES :
(
	Internal_Comm_OK := 1,
	Waiting_For_MOM := 2,
	Configuring_MOM := 4,
	Internal_Comm_Disabled := 8,
	No_Comm_To_Configured_Node := 127
);
END_TYPE
