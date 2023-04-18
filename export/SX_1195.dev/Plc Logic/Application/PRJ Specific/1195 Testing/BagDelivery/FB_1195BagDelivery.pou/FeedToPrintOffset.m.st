(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedToPrintOffset
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF state = eBagDeliveryStates.Idle THEN
	state := eBagDeliveryStates.FeedToPrintOffset;
	ClearStatus();
END_IF
			