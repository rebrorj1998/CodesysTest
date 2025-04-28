(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE BAG_OPEN_ASSIST_STATES :
(
	Idle := 0,
	MoveJawIn := 10,
	MovingJawIn := 11,
	MovedJawIn := 12,
	MoveJawOut := 20,
	MovingJawOutAndGrab := 21,
	CheckForSuccessfulBagGrab := 22,
	BagFailedToOpen := 23,
	OpenBag := 24,
	BagOpening := 25,
	BagOpened := 26,
	MovingJawOutAfterGrab := 27,
	MovedJawOut := 28,
	FeedNewBag := 29,
	Done := 100,
	Fault := 99
);
END_TYPE
