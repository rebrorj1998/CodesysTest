(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE eAppliedMotionHomingStates :
(
    Idle := 0,
    MoveForwardFromSensor := 10,
    MovingForwardFromSensor := 11,
	ClearToHome := 12,
    StartHoming := 13,
    Homing := 14,
    HomeComplete := 15,
	MoveToDesiredPassthrough := 16, 
	MovingToDesiredPassthrough := 17,
	SetLimits := 18
	
);
END_TYPE
