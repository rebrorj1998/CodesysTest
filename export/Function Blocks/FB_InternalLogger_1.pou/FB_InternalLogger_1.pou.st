(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_InternalLogger_1 IMPLEMENTS IMachineLogger
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

RTC();

IF clearLog THEN
	FOR i := 0 TO Globals.MAX_LOGGED_ITEMS BY 1 DO
		loggedItems[i].logMessage := '';
		loggedItems[i].logTime := DT#1970-1-1-1:0:0;
	END_FOR
	numOfLogEntries := 0;
	logFull := FALSE;
	clearLog := FALSE;
END_IF