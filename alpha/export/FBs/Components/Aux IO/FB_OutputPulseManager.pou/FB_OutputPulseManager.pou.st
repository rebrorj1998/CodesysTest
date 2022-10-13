(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_OutputPulseManager
VAR_INPUT
END_VAR
VAR_OUTPUT
	configOut1 : BOOL;
	configOut2 : BOOL;
	configOut3 : BOOL;
	configOut4 : BOOL;
END_VAR
VAR
	_reset : BOOL;
	_configOutput1Pulse : FB_MonostableMultivibrator();
	_configOutput2Pulse : FB_MonostableMultivibrator();
	_configOutput3Pulse : FB_MonostableMultivibrator();
	_configOutput4Pulse : FB_MonostableMultivibrator();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)


IF _reset THEN
	_reset := FALSE;
	_configOutput1Pulse.Reset();
	_configOutput2Pulse.Reset();
	_configOutput3Pulse.Reset();
	_configOutput4Pulse.Reset();
	_configOutput1Pulse.ManualOff();
	_configOutput2Pulse.ManualOff();
	_configOutput3Pulse.ManualOff();
	_configOutput4Pulse.ManualOff();
END_IF

// Pulse outputs that are temporary statuses (Cycle Complete) vs. held (Waiting for Printer) 
_configOutput1Pulse(Q => configOut1);
_configOutput2Pulse(Q => configOut2);
_configOutput3Pulse(Q => configOut3);
_configOutput4Pulse(Q => configOut4);
_configOutput1Pulse.DwellSetting := 500;
_configOutput2Pulse.DwellSetting := 500;
_configOutput3Pulse.DwellSetting := 500;
_configOutput4Pulse.DwellSetting := 500;