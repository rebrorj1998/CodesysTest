(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Clear
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_idleState := FALSE;
_enable := FALSE;
_disable := FALSE;
_feedToLength := FALSE;
_feedToPosition := FALSE;
_feedToSensor := FALSE;
_feedToDoubleSensor := FALSE;
_feedToSensorSafety := FALSE;
_feedToSensorMask := FALSE;
_feedAndSetOutput := FALSE;
_feedSpeedChange := FALSE;
_seekHome := FALSE;
_findHome := FALSE;
_followEncoder := FALSE;
_stopAndKillCrash := FALSE;
_stopAndKillNormal := FALSE;
_startJog := FALSE;
_updateJogSpeed := FALSE;
_sendHostCommand := FALSE;
_sendQAndExecute := FALSE;
_alarmReset := FALSE;