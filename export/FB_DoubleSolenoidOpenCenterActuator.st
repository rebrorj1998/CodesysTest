

FUNCTION_BLOCK FINAL FB_DoubleSolenoidOpenCenterActuator EXTENDS FB_DoubleSolenoidClosedCenterActuator IMPLEMENTS IExhaustable
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR



METHOD Exhaust : BOOL

THIS^.solenoid0 := FALSE;
THIS^.solenoid1 := FALSE;