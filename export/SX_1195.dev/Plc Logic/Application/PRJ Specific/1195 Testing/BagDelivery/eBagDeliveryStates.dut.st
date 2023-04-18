(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eBagDeliveryStates :
(
	Idle := 0,
	FeedBagOut := 1,
	FeedingBagOut := 2,
	FeedToPrintOffset := 3,
	FeedingToPrintOffset := 4,
	ReverseToSeperate := 5,
	ReversingToSeperate := 6,
	FeedToPhotoEye := 8,
	FeedingToPhotoEye := 9,
	FeedAtPrintSpeed := 11,
	FeedingAtPrintSpeed := 12,
	Cleanup := 13,
	WaitingForMoveCompletion := 14,
	Reset := 200, 
	Resetting := 201, 
	ResetDone := 202
);
END_TYPE
