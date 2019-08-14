

FUNCTION_BLOCK FB_SolenoidValve EXTENDS FB_BaseObject IMPLEMENTS ISolenoidValve, ISimulateable
VAR_INPUT
	
END_VAR
VAR_OUTPUT
	solenoid0 : BOOL;
	solenoid1 : BOOL;
END_VAR
VAR
	_simulateActive : BOOL;
END_VAR



PROPERTY Simulate : BOOL


PROPERTY Solenoid0Asserted : BOOL


PROPERTY Solenoid1Asserted : BOOL
