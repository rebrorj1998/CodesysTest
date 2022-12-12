(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ManualOn
VAR_INPUT
	output : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE output OF
	1: _configOutput1Pulse.ManualOn();
	2: _configOutput2Pulse.ManualOn();
	3: _configOutput3Pulse.ManualOn();
	4: _configOutput4Pulse.ManualOn();
END_CASE