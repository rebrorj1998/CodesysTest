(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE eClampingMechanismStates :
(
	Idle := 0,
	ClampMoveToClamp := 10,
	ClampMovingToClamp := 11,
	ClampMovedToClamp := 12,
	Clamping := 20,
	ClampMoveToRelease := 30, 
	ClampMovingToRelease := 31, 
	ClampMovedToRelease := 32,
	Fault := 100, 
	Faulting := 101,
	Faulted := 102, 
	Reset := 110, 
	Resetting := 111, 
	ResetDone := 112,
	Home:= 40,
	Homing:= 50
);
END_TYPE
