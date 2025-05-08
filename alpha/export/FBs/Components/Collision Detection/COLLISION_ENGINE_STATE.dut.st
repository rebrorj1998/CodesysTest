(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE COLLISION_ENGINE_STATE :
(
	Idle := 0,
	PackageAtExit := 1,
	PackageHeldAtExit := 2,
	ConveyPackagesPastExitSensor := 3,
	ConveySecondPackagePastExitSensor := 4,
	WaitForPackageToReachTrunkline := 5,
	runConveyors := 6,
	ConveyFirstPackage := 7,
	WaitForSecondPackage := 8,
	ConveySecondPackage := 9
);
END_TYPE
