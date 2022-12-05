(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE AUTOMATION_STATES :
(
	Idle := 0,
	MoveSealFlattenersIn := 1,
	MovingSealFlattenersIn := 2,
	MovedSealFlattenersIn := 3,
	DisableBagOpenSensing := 4,
	RaiseBOF := 5,
	Done := 6
);
END_TYPE
