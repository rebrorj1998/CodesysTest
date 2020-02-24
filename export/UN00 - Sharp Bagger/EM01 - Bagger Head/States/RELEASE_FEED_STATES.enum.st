(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE RELEASE_FEED_STATES :
(
	Idle := 0,
	MoveJawOutAndFeedBag := 10,
	WaitForOKFromDischarge := 11,
	MovingJawOutAndFeedingBag := 12,
	MovedJawOutAndFedBag := 13,
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
