(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ReverseToSeparate
VAR_INPUT
	//dryCycleEnable : BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF state = eBagDeliveryStates.Idle THEN
	//_dryCycle := dryCycleEnable;
	state := eBagDeliveryStates.ReverseToSeperate;
	ClearStatus();
END_IF