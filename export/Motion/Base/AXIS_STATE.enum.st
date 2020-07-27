(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE AXIS_STATE :
(
	AS_PowerOff := 0,
	AS_ErrorStop := 1,
	AS_Stopping := 2,
	AS_Standstill := 3,
	AS_DiscreteMotion := 4,
	AS_ContinuousMotion := 5,
	AS_Homing := 7
);
END_TYPE
