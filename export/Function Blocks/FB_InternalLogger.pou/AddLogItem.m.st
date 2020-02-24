(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AddLogItem
VAR_INPUT
	//category : STRING;
	message : STRING;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR i := Globals.MAX_LOGGED_ITEMS -1 TO 1 BY -1 DO
		loggedItems[i] := loggedItems[i-1];
END_FOR
//loggedItems[0].logCategory := category;
loggedItems[0].logMessage := message;
loggedItems[0].logTime := RTC.currentDateAndTime;