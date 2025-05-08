(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE PacAlarm :
STRUCT
	ID : INT;
	Value : INT;
	Message : STRING;
	TimeEvent : PackTimeStamp;
	TimeAck : PackTimeStamp;
END_STRUCT
END_TYPE
