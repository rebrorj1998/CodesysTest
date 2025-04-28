(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE BAG_DELIVERY_STATES :
(
	Idle := 0,
	Reverse := 1,
	Reversing := 2,
	ReverseToPrinthead := 3,
	Sync := 1001,
	ReversingToPrintHead := 4,
	ReverseDone := 5,
	WaitingForPrinter := 10,
	FeedToPrintOffset := 11,
	FeedingToPrintOffset := 12,
	CreateSlack := 70,
	CreatingSlack := 71,
	CreatedSlack := 72,
	FedToPrintOffset := 13,
	FeedAtPrintSpeed := 20,
	FeedingAtPrintSpeed := 21,
	FedAtPrintSpeed := 22,
	FeedBagOut := 30,
	FeedingBagOut := 31,
	FedBagOut := 32,
	FeedToSeal := 60,
	FeedingToSeal := 61,
	FedToSeal := 62,
	Ready := 40,
	FeedToEye := 50,
	FeedingToEye := 51,
	SetTorqueMode := 52,
	SetTorqueValue := 53,
	Fault := 99,
	Manual := 100,
	Reset := 110,
	Resetting := 111
);
END_TYPE
