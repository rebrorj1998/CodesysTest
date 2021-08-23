(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE COLLISION_ENGINE_STATE :
(
	Idle := 0,
	PackageAtExit := 1,
	PackageHeldAtExit := 2,
	ConveyPackagesPastExitSensor := 3,
	ConveySecondPackagePastExitSensor := 4
);
END_TYPE
