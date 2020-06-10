(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAppliedMotionDriveStatesASCII :
(
	Idle := 0,
	MoveABS := 10,
	MovePush := 11,
	MoveInc := 12,
	SendPars := 40,
	SendOpcodeAfterPars := 41,
	StartJogging := 20,
	Jogging := 21,
	Moving := 50,
	DoneMoving := 51,
	Halt := 60,
	Halting := 61,
	Halted := 62,
	Home := 70,
	Homing := 71,
	Faulting := 98,
	Faulted := 99
);
END_TYPE
