(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD GetDailyLogString : STRING(1000)
VAR_INPUT
END_VAR
VAR
	_logstring : STRING(1000);
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_logString := '';
_logString := CONCAT(_logString,TO_STRING(faultedTimeInHours));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(faultedPercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(idleTimeInHours));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(idlePercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(availableTimeInHours));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(availablePercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(qualityFaults));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(bagsMade));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(qualityPercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(blockedTimeInHours));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(blockedPercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(runningTimeInHours));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(runningPercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(throughputPercent * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,TO_STRING(OEE * 100.0));
_logString := CONCAT(_logString,',');
_logString := CONCAT(_logString,_readableTime);
GetDailyLogString := _logString;
