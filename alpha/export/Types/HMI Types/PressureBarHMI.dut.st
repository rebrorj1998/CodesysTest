(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE PressureBarHMI :
STRUCT
	openDelay : UINT;
	closeDelay : UINT;
	passthroughSetting : REAL;
	lowPressureAirDwell : REAL;
	highPressureAirDwell : REAL;
END_STRUCT
END_TYPE
