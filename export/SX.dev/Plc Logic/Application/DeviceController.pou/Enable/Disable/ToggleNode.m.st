(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PUBLIC ToggleNode : DED.ERROR
VAR_INPUT
	itfNode				: DED.INode;
	xEnable				: BOOL;				(* TRUE: Enable all devices of eBus. FALSE: Disable all devices of eBus. *)
END_VAR
VAR
	itfReconfigureNode 	: DED.INode;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF itfNode <> 0 THEN
	
	(* reconfigure is only possible if device controller is in idle state *)
	IF _iState = 0 THEN
			
		(* search for the top most reconfigure provider *)
		itfReconfigureNode := GetReconfigureProvider(itfNode);
		
		(* found the top most node which supports reconfigure? *)
		IF itfReconfigureNode <> 0 THEN
			
			(* toggle if node is in different state only *)
			IF itfNode.Enable <> xEnable THEN
				(* step one of reconfigure process: Set Enable Property. *)
				itfNode.Enable := xEnable;
				(* step two: perform reconfigure *)
				_itfNodeToReconfigure := itfReconfigureNode;
				_iState := 10;
			END_IF
			
		ELSE
			(* there is no parent node supporting reconfigure... *)
			ToggleNode := DED.ERROR.NOT_SUPPORTED;
		END_IF
		
	ELSE
		(* device controller is not ready to reconfigure. *)
		ToggleNode := DED.ERROR.OPERATION_INVALID;
	END_IF
	
ELSE
	(* itfNode should not be 0... *)
	ToggleNode := DED.ERROR.PARAM_INVALID;
END_IF