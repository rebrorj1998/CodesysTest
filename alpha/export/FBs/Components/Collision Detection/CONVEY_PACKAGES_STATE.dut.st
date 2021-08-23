(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE CONVEY_PACKAGES_STATE :
(
	Idle := 0,
	StartConveyor := 1,
	ConveyFirstPackage := 2,
	WaitForSecondPackage := 3,
	ConveySecondPackage := 4,
	Runoff := 5,
	ConveyorCleared := 6
);
END_TYPE
