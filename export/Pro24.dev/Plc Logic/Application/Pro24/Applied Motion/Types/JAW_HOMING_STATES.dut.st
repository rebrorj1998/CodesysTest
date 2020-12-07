(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE JAW_HOMING_STATES :
(
    Idle := 0,
    MoveForwardFromSensor := 10,
    MovingForwardFromSensor := 11,
	ClearToHome := 12,
    StartHoming := 13,
    Homing := 14,
    HomeComplete := 15,
	MoveToTwoInches := 16, 
	MovingToTwoInches := 17,
	SetLimits := 18
	
);
END_TYPE
