(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE eBagDeliveryStates :
(
	Idle := 0,
	FeedBagOut := 1,
	FeedingBagOut := 2,
	FeedToPrintOffset := 3,
	FeedingToPrintOffset := 4,
	
	ReverseToSeperate := 5,
	ReversingToSeperate := 6,
	ReversingToSeperateDone:=7,
	FeedToPhotoEye := 8,
	FeedingToPhotoEye := 9,
	FeedToPhotoEyeDone:=10,
	FeedAtPrintSpeed := 11,
	FeedingAtPrintSpeed := 12,
	Cleanup := 13,
	WaitingForMoveCompletion := 14,
	MoveComplete := 15,
	Reset := 200, 
	Resetting := 201, 
	ResetDone := 202
);
END_TYPE
