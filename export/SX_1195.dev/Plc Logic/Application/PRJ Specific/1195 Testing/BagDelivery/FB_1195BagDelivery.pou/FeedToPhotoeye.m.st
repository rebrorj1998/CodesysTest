(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedToPhotoeye
VAR_INPUT
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF state = eBagDeliveryStates.Idle THEN
	IF NOT bagPresent THEN
		THIS^.ClearStatus();
		state := eBagDeliveryStates.FeedToPhotoEye;
	END_IF
END_IF