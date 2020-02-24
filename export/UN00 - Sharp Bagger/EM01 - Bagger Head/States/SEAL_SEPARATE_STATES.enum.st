(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE SEAL_SEPARATE_STATES :
(
	Idle := 0,
	MoveJawIn := 10,
	MovingJawIn := 11,
	MovedJawIn := 12,
	ReverseBag := 20,
	ReversingBag := 21,
	ReversedBag := 22,
	SealBag := 30, 
	SealingBag := 31, 
	SealedBag := 32,
	Done := 100,
	Fault := 99
);
END_TYPE
