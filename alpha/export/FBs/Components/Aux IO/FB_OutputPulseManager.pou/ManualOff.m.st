(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ManualOff
VAR_INPUT
	output : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE output OF
	1: _configOutput1Pulse.ManualOff();
	2: _configOutput2Pulse.ManualOff();
	3: _configOutput3Pulse.ManualOff();
	4: _configOutput4Pulse.ManualOff();
END_CASE