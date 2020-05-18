(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
(* Reset a device *)
METHOD PUBLIC Reset : DED.ERROR
VAR_INPUT
	itfDevice : DED.IDevice2;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF itfDevice <> 0 THEN
	
	(* with CheckSupportedCommunicationState() it is possible to check whether the requested state can be performed in general. *)
	IF itfDevice.CheckSupportedCommunicationState(DED.DEVICE_TRANSITION_STATE.RESET) THEN
		
		(* with CheckCurrentSupportedCommunicationState() it is possible to check whether the device can be reset right now. *)
		IF itfDevice.CheckCurrentSupportedCommunicationState(DED.DEVICE_TRANSITION_STATE.RESET) THEN
			(* reset the device*)
			itfDevice.SetCommunicationState(DED.DEVICE_TRANSITION_STATE.RESET);
		ELSE
			(* device is not ready to be reset. *)
			Reset := DED.ERROR.OPERATION_INVALID;
		END_IF
	ELSE
		(* device does not support "Reset" *)
		Reset := DED.ERROR.NOT_SUPPORTED;
	END_IF
	
END_IF