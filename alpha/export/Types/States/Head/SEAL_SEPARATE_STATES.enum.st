(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE SEAL_SEPARATE_STATES :
(
	Idle := 0,
	Shake := 6,
	Shaking := 7, 
	BringInIBD := 8,
	WaitForJawCloseDelay := 9,
	MoveJawIn := 10,
	MovingJawIn := 11,
	MovedJawIn := 12,
	ReverseBag := 20,
	ReversingBag := 21,
	ReversedBag := 22,
	SealBag := 30, 
	SealingBag := 31, 
	SealedBag := 32,
	PrepareToFeedToSeal := 40,
	PreparingToFeedToSeal := 41,
	PreparedToFeedToSeal := 42,
	FeedToSeal := 43,
	FeedingToSeal := 44,
	FedToSeal := 45,
	Done := 100,
	Fault := 99
);
END_TYPE
