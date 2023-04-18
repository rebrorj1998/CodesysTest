(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mVeloAccDecCalc : INT
VAR_INPUT
	value : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Value = Feed (in inches) per second
// The drive units are .25 RPM so you have to multiple by 60 to get RPMS then multiply by 4 
mVeloAccDecCalc := TO_INT( FPU.CeilF((value * REVS_PER_INCH_OF_FEED) * UNITS_PER_ROTATION * RPS_TO_RPM));