(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ElectricSolenoid EXTENDS FB_BaseObject IMPLEMENTS ISimulateable, IUpDown
VAR_INPUT
	downFeedback : BOOL;
END_VAR
VAR_OUTPUT
	actuateSolenoid : BOOL;
END_VAR
VAR
	_simulateActive : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
