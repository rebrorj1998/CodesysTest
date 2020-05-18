(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
(* Start a device *)
METHOD PUBLIC Start : DED.ERROR
VAR_INPUT
	itfDevice : DED.IDevice2;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF itfDevice <> 0 THEN
	
	(* with CheckSupportedCommunicationState() it is possible to check whether the requested state can be performed in general. *)
	IF itfDevice.CheckSupportedCommunicationState(DED.DEVICE_TRANSITION_STATE.START) THEN
			
		(* with CheckCurrentSupportedCommunicationState() it is possible to check whether the device can be started right now. *)
		IF itfDevice.CheckCurrentSupportedCommunicationState(DED.DEVICE_TRANSITION_STATE.START) THEN
			(* start the device *)
			itfDevice.SetCommunicationState(DED.DEVICE_TRANSITION_STATE.START);
		ELSE
			(* device is not ready to start. *)
			Start := DED.ERROR.OPERATION_INVALID;
		END_IF
	ELSE
		(* device does not support "Start" *)
		Start := DED.ERROR.NOT_SUPPORTED;
	END_IF
	
END_IF