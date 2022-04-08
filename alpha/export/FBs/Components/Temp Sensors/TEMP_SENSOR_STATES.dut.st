(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE TEMP_SENSOR_STATES :
(
	Idle := 0,
	ReconfigureIO := 1,
	ReconfiguringIO := 2,
	ReconfiguredIO := 3
);
END_TYPE
