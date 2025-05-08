(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL
	runningTime : TIME;
	faultedTime : TIME;
	blockedTime : TIME;
	bagsMade : DINT;
	qualityFaults : DINT;
	availableTime : TIME;
	expectedPackagePerMinuteRate : REAL := 4.66;
END_VAR