(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ProfaceInterface
VAR_INPUT
	interfaceArray : ARRAY[0..20] OF INT;
END_VAR
VAR_OUTPUT
	currentScreenNumber : UINT;			// Active screen on Proface Panel
	error : sctProfaceErrorStatus;		// Error status
	dtFromPanel : DATE_AND_TIME;		// Date and Time from Proface Panel
	status : sctProfaceStatus;			// Panel Status
	changeScreenNumber : UINT;			// Change screen number
	setDisplay : UINT;					// Turn Screen Display OFF with FFFFh Display screen with 0h
	setYear : UINT;						// Last 2 digits of year (2 BCD digits) (Bit 15 is a flag to set clock data)
	setMonth : UINT;
	setDay : UINT;
	setTime : UINT;
	controlWord : UINT;					// Control word
	winControl : UINT;				// Window control
	winNumber : UINT;
	winXPos : UINT;
	winYPos : UINT;
END_VAR
VAR
	control : sctProfaceControl;
END_VAR
VAR_IN_OUT
	
END_VAR
VAR CONSTANT
	SCREEN_ON : UINT := 16#FFFF;
	SCREEN_OFF : UINT := 0;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
