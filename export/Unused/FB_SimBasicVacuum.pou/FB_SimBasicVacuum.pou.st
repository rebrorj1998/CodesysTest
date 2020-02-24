(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SimBasicVacuum EXTENDS FB_BaseComponent IMPLEMENTS IVacuumBagOpen, IExecuteAutomatically
VAR_INPUT
	vacGrabDwell : REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	startVac : FB_SimulatedFeedback(name := CONCAT(_prefix,'Start Vac'));
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
