(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PneumaticActuator EXTENDS FB_SolenoidValve IMPLEMENTS ICylinder
VAR_INPUT

END_VAR
VAR_OUTPUT
END_VAR
VAR
	_extendAsserted : BOOL;
	_isExtended : BOOL;
	_retractAsserted : BOOL;
	_isRetracted : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
