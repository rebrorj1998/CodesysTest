(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE AUTOMATION_STATES :
(
	Idle := 0,
	MoveSealFlattenersUp := 1,
	MovingSealFlattenersUp := 2,
	MoveSealFlattenersOut := 3,
	MovingSealFlattenersOut := 4,
	MovedSealFlattenersIn := 5,
	DisableBagOpenSensing := 6,
	RaiseBOF := 7,
	Done := 8
);
END_TYPE
