(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE LogMessageType :
STRUCT
	logTime : DATE_AND_TIME;
	logCategory : STRING;
	logMessage : STRING;
END_STRUCT
END_TYPE
