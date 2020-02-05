(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE TEST_HEAD_STATES :
(
	Idle := 0,
	Cycling := 10,
	StartHoming := 20,
	Homing := 21,
	HomingComplete := 22,
	MovePassthrough := 30,
	MovingPassthrough := 31,
	MovedPassthrough := 32,
	Fault := 99
);
END_TYPE
