(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctProfaceStatus :
STRUCT
	printing : BOOL; 		// Printing Active 
	partWriteStatus : BOOL;	// Data Display Part Write Setting Value
	displayOff : BOOL;		// Display On/Off. 0=Off, 1=On
	backlightBurnout : BOOL;// Detect Backlight Burnout
END_STRUCT
	
END_TYPE
