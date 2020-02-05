(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE RELEASE_FEED_STATES :
(
	Idle := 0,
	MoveJawOutAndDropBag := 10,
	MovingJawOutAndDroppingBag := 11,
	MovingJawOutAndFeedBag := 12,
	MovingJawOutAndFeedingBag := 13,
	MovedJawOutAndFedBag := 15,
	WaitForPrinter := 20,
	FeedToOffset := 21,
	FeedingToOffset := 22,
	StartPrinting := 23,
	SendPrintSignal := 24,
	Printing := 25, 
	StopPrinting := 26,
	Done := 100,
	Fault := 99
);
END_TYPE
