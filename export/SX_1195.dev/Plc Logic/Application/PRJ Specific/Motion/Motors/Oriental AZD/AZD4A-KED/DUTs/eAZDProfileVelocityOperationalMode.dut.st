(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAZDProfileVelocityOperationalMode :
(
	PositionControl := 0,
	SpeedControl := 1,
	PushMotion := 2,
	TorqueControl := 3
) SINT;
END_TYPE
