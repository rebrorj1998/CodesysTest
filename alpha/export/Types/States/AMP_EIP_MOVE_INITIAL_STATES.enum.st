(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE AMP_EIP_MOVE_INITIAL_STATES :
(
	Idle := 0,
	SetOutputOff := 10,
	AckOutputOff := 1,
	WaitAfterSettingOutputOff := 11,
	MoveMotor := 12,
	WaitAfterMovingMotor := 13,
	SetOutputOn := 14,
	AckOutputOn := 2,
	WaitAfterSettingOutputOn := 15,
	Fault := 99
);
END_TYPE
