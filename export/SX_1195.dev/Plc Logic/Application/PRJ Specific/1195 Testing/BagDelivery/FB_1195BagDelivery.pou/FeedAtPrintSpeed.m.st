(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedAtPrintSpeed
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF state = eBagDeliveryStates.Idle THEN
	state := eBagDeliveryStates.FeedAtPrintSpeed;
	ClearStatus();
END_IF