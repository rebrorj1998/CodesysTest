(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE HEAD_STATES :
(
	Idle := 0,
	DropProduct := 1,
	DroppingProduct := 2,
	DroppedProduct := 3,
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
	StartReset := 50,
	Resetting := 51,
	PassthroughPreCheck := 52,
	StartHoming := 53,
	Homing := 54,
	HomingComplete := 55,
	MovePassthrough := 60,
	MovingPassthrough := 61,
	MovedPassthrough := 62,
	Stopping := 70,
	PrepareForAutomatedBagRemoval := 80,
	PreparingForAutomatedBagRemoval := 81,
	PreparedForAutomatedBagRemoval := 82,
	Fault := 99
);
END_TYPE
