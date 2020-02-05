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
	BagOpened := 24,
	MovingJawOutAfterGrab := 25,
	MovedJawOut := 26,
	FeedNewBag := 27,
	Done := 100,
	Fault := 99
);
END_TYPE
