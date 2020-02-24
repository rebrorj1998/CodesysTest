(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION FirstScan : DWORD
VAR_IN_OUT
	EventPrm: CmpApp.EVTPARAM_CmpApp;
END_VAR
VAR
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Set first scan flag from StartDone system event
Globals.firstScan := TRUE;