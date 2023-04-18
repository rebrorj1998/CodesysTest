(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedBagOut
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF state = eBagDeliveryStates.Idle THEN
	state := eBagDeliveryStates.FeedBagOut;
	ClearStatus();
END_IF