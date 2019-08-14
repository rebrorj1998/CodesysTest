

FUNCTION_BLOCK FB_DoubleSolenoidClosedCenterActuator EXTENDS FB_PneumaticActuator IMPLEMENTS IExtendLowPressure
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	
END_VAR



PROPERTY ExtendAsserted : BOOL


PROPERTY RetractAsserted : BOOL


METHOD Extend

THIS^.solenoid0 := TRUE;
THIS^.solenoid1 := FALSE;

METHOD Retract

THIS^.solenoid0 := FALSE;
THIS^.solenoid1 := TRUE;

METHOD ExtendLowPressure
VAR_INPUT
END_VAR

THIS^.solenoid0 := TRUE;
THIS^.solenoid1 := TRUE;

PROPERTY ExtendLPAsserted : BOOL