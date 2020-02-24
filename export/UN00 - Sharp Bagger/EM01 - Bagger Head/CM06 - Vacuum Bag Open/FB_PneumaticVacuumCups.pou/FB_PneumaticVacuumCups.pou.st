(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PneumaticVacuumCups EXTENDS FB_BaseComponent IMPLEMENTS IVacuumBagOpen
VAR_INPUT
	
END_VAR
VAR_OUTPUT
	
END_VAR
VAR
	_vacuumOn : BOOL;
END_VAR
VAR_IN_OUT
	vacGenerator : FB_VacuumGenerator;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();