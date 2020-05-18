(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
(* Stop a device *)
METHOD PUBLIC Stop : DED.ERROR
VAR_INPUT
	itfDevice : DED.IDevice2;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF itfDevice <> 0 THEN
	
	(* with CheckSupportedCommunicationState() it is possible to check whether the requested state can be performed in general. *)
	IF itfDevice.CheckSupportedCommunicationState(DED.DEVICE_TRANSITION_STATE.STOP) THEN
		
		(* with CheckCurrentSupportedCommunicationState() it is possible to check whether the device can be stopped right now. *)
		IF itfDevice.CheckCurrentSupportedCommunicationState(DED.DEVICE_TRANSITION_STATE.STOP) THEN
			(* stop the device *)
			itfDevice.SetCommunicationState(DED.DEVICE_TRANSITION_STATE.STOP);
		ELSE
			(* device is not ready to be stopped. *)
			Stop := DED.ERROR.OPERATION_INVALID;
		END_IF
	ELSE
		(* device does not support "Stop" *)
		Stop := DED.ERROR.NOT_SUPPORTED;
	END_IF
	
END_IF