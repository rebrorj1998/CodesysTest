(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
VAR CONSTANT
	UNITS_PER_ROTATION : REAL := 4.0;
	RPS_TO_RPM : REAL := 60;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ScaledProfileVelocity := FPU.CeilF(profileVelocity * rotationsPerInch * UNITS_PER_ROTATION * RPS_TO_RPM); 