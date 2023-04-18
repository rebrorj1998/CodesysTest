(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF commandSuccessful THEN
	IF _previousCommandWord.20 <> 0 THEN
		_previousCommandWord := 0;
	ELSE
		commandSuccessful := FALSE;
		_alarmReset := AlarmReset;
	END_IF
END_IF
