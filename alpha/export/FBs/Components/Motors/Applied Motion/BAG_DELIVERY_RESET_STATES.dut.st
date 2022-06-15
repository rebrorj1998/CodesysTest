(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE BAG_DELIVERY_RESET_STATES :
(
	Idle := 0,
	ClearFaults := 1,
	SetTorque := 2,
	SettingTorque := 3,
	TorqueSet := 4,
	SetTorqueMode := 5,
	SettingTorqueMode := 6,
	TorqueModeSet := 7
);
END_TYPE
