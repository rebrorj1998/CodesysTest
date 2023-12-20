(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE eMotorizedLoadPlateStates :
(
	Idle := 0,
	Lower := 10,
	Lowering := 11, 
	Lowered := 12,
	Raise := 20,
	Raising := 21, 
	Raised := 22,
	Home := 30,
	Homing := 31, 
	Faulting := 98,
	Faulted := 99,
	Reset := 100, 
	Resetting := 101
);
END_TYPE
