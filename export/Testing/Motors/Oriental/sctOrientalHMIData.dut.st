(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctOrientalHMIData :
STRUCT
	CommandedPos : REAL;
	ActPos : REAL;
	CurrentAlarmCode : DWORD;
	setPreset : BOOL;
	freeMotor : BOOL;
END_STRUCT
END_TYPE
