(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
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
	StartHoming := 40,
	Homing := 41,
	HomingComplete := 42,
	MovePassthrough := 50,
	MovingPassthrough := 51,
	MovedPassthrough := 52,
	Fault := 99
);
END_TYPE
