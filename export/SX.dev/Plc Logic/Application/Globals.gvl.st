(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL
	SystemLog : FB_InternalLogger;
	
END_VAR

VAR_GLOBAL CONSTANT
	MAX_LOGGED_ITEMS : UINT := 500;	// Max items to be logged
	STEPS_PER_INCH_IBD : DINT := 1250;
	STEPS_PER_INCH_JAW : DINT := 1250;
	STEPS_PER_INCH_LOAD_PLATE : DINT := 931;
	STEPS_PER_INCH_FILM : DINT := 1000;
	SERIAL_BUFFER_SIZE : BYTE := 50;
END_VAR