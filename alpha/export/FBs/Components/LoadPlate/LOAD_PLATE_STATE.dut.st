(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE LOAD_PLATE_STATE :
(
	Idle := 0,
	Shake := 1,
	Shaking := 2,
	Shaked := 3
);
END_TYPE
