(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_InternalLogger IMPLEMENTS IMachineLogger
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	//loggedItems : ARRAY[0..500] OF FaultLogType;
	loggedItems : ARRAY[0..Globals.MAX_LOGGED_ITEMS] OF LogMessageType;
	numOfLogEntries : UINT;
	logFull : BOOL;
	RTC : FB_GetTime();
	clearLog : BOOL;
	i : UINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_Logger
//	Description: This is an internal logger for reference within Codesys.  It is an array that can be displayed on the TargetVisu/WebVisu 
//	
//	Created by: Ben Hess
//	Created Date: Tuesday, September 11, 2018

// DISABLED LOGGING FOR CREVIS PLC - SCAN TIMES OUT OF CONTROL