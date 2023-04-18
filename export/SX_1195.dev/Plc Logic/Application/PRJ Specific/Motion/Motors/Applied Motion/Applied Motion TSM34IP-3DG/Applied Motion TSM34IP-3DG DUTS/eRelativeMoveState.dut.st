(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eRelativeMoveState :
(
	Idle := 0,
	SetOutputOff := 10,
	WaitAfterSettingOutputOff := 11,
	MoveMotor := 12,
	WaitAfterMovingMotor := 13,
	SetOutputOn := 14,
	WaitAfterSettingOutputOn := 15,
	Fault := 99
);
END_TYPE
