(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE HEAD_STATES :
(
	Idle := 0,
	SealAndSeparateBag := 10,
	SealingAndSeparatingBag := 11,
	SealedAndSeparatedBag := 12,
	ReleaseAndFeedBag := 20,
	ReleasingAndFeedingBag := 21,
	ReleasedAndFedBag := 22,
	OpenBag := 30,
	OpeningBag := 31,
	OpenedBag := 32,
	FinishCycle := 40, 
	FinishingCycle := 41,
	FinishedCycle := 42,
	StartHoming := 50,
	Homing := 51,
	HomingComplete := 52,
	MovePassthrough := 60,
	MovingPassthrough := 61,
	MovedPassthrough := 62,
	Fault := 99
);
END_TYPE
