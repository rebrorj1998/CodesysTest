(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE eDualMotorPbarHomingStates :
(
	Idle := 0,
	MoveBothMotorsOutToClear := 10,
	MovingBothMotorsOutToClear := 11,
	MovedBothMotorsOutToClear := 12,
	ZHomeBothMotors := 13,
	ZHomingBothMotors := 14,
	MoveMotorsToPassthrough := 15, 
	MovingMotorsToPassthrough := 16,
	MovedMotorsToPassthrough := 17
);
END_TYPE
