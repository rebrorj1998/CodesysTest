(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAxisState :
(
	PowerOff := 0,
	ErrorStop := 1,
	Stopping := 2,
	Halting := 8,
	Standstill := 3,
	DiscreteMotion := 4,
	ContinuousMotion := 5,
	Homing := 7
);
END_TYPE
