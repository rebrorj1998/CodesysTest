(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Trigger
VAR_INPUT
	output : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE output OF
	1: _configOutput1Pulse.Trigger();
	2: _configOutput2Pulse.Trigger();
	3: _configOutput3Pulse.Trigger();
	4: _configOutput4Pulse.Trigger();
END_CASE