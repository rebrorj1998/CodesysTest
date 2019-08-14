

FUNCTION_BLOCK FB_SingleSolenoidNormallyRetractedActuator EXTENDS FB_PneumaticActuator IMPLEMENTS ICylinder
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR



PROPERTY ExtendAsserted : BOOL


PROPERTY RetractAsserted : BOOL


METHOD Extend

solenoid0 := TRUE;

METHOD Retract

solenoid0 := FALSE;

FUNCTION_BLOCK FB_SingleSolenoidNormallyRetractedActuator EXTENDS FB_PneumaticActuator IMPLEMENTS ICylinder
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR



PROPERTY ExtendAsserted : BOOL


PROPERTY RetractAsserted : BOOL


METHOD Extend

solenoid0 := TRUE;

METHOD Retract

solenoid0 := FALSE;