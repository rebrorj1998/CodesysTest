(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'io_function_block'}
FUNCTION_BLOCK FB_PhysicalDigitalInput EXTENDS FB_BaseObject IMPLEMENTS IExecuteAutomatically
VAR_INPUT
	in : REFERENCE TO BOOL;
	simulate : BOOL;
	simValue : BOOL;
	debounceEnable : BOOL;	// 
	debounceTime : REAL := 50.0;		// Debounce time in MS
END_VAR
VAR_OUTPUT
	Active : BOOL;
	OSR : BOOL;
	OSF : BOOL;
END_VAR
VAR
	debounceTimer : TON;
	inputONS : FB_ONS();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
