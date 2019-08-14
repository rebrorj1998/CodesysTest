

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



PROPERTY ExtendAsserted : BOOL


PROPERTY IsExtended : BOOL


PROPERTY IsRetracted : BOOL


PROPERTY RetractAsserted : BOOL


METHOD Extend

_extendAsserted := TRUE;
_retractAsserted := FALSE;

METHOD Retract

_extendAsserted := FALSE;
_retractAsserted := TRUE;