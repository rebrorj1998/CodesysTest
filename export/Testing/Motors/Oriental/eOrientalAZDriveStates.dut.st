(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eOrientalAZDriveStates :
(
	Idle := 0,
	MoveABS := 10,
	MovePush := 11,
	MoveInc := 12,
	Jogging := 20,
	Moving := 50,
	DoneMoving := 51,
	Halt := 60,
	Halting := 61,
	Halted := 62,
	Home := 70,
	Homing := 71,
	SetPreset := 80,
	SetPresetDone := 81,
	DelayAfterWrite := 97,
	Faulting := 98,
	Faulted := 99,
	Resetting := 101
);
END_TYPE
