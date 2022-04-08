(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE BAG_DELIVERY_MOVE_STATES :
(
	Idle := 0,
	SetToPointToPointMode := 10,
	AckPointToPointMode := 1,
	WaitAfterSettingOutputOff := 11,
	MoveMotor := 12,
	WaitAfterMovingMotor := 13,
	SetToTorqueMode := 14,
	AckTorqueMode := 2,
	WaitAfterSettingOutputOn := 15,
	Fault := 99
);
END_TYPE
