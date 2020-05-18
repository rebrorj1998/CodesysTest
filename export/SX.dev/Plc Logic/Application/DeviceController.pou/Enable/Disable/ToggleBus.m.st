(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PUBLIC ToggleBus : DED.ERROR
VAR_INPUT
	eBus			: DED.BUS_TYPE;		(* Specify the bus type e.g. ETHERNET or ETHERNET_IP, ...*)
	eDeviceType		: DED.DEVICE_TYPE;	(* optional: Specifiy the device type e.g. FIELDBUS_MASTER. If DED.DEVICE_TYPE.UNKNOWN input will be ignored. *)
	uiInstance 		: UINT := 1;		(* the n-th subtree of this eBus. E.g. if there are two CANbus' configured, set uiInstance := 2 to enable the second CANbus. *)
	xEnable			: BOOL;				(* TRUE: Enable all devices of eBus. FALSE: Disable all devices of eBus. *)
END_VAR
VAR
	uiTmpInstance 	: UINT;
	xBusTypeMatch   : BOOL;
	xDeviceTypeMatch : BOOL;
	itfNode			: DED.INode;
	itfBus			: DED.IBus;
	itfDevice		: DED.IDevice;
	strBusInfo		: DED.BUS_INFO;
	strDeviceInfo	: DED.DEVICE_INFO;
	itfReconfigureNode 	: DED.INode;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _iState = 0 THEN
		
	(* first we need to find the requested bus by parsing the device tree *)
	itfNode := DED.GetRoot();
	REPEAT
		xBusTypeMatch := FALSE;
		xDeviceTypeMatch := FALSE;
		itfNode := GetNextNode(itfNode);
		IF itfNode <> 0 THEN
			(* check if this node implements IBus *)
			itfBus := DED.INode_TO_IBus(itfNode);
			IF itfBus <> 0 THEN
				(* check if this is the requested bus *)
				itfBus.GetBusInfo(strBusInfo);
				IF strBusInfo.eType = eBus THEN
					xBusTypeMatch := TRUE;
				END_IF
			END_IF	

			IF eDeviceType <> DED.DEVICE_TYPE.UNKNOWN THEN
				itfDevice := DED.INode_TO_IDevice(itfNode);
				IF itfDevice <> 0 THEN
					itfDevice.GetDeviceInfo(strDeviceInfo);
					IF strDeviceInfo.eType = eDeviceType THEN
						xDeviceTypeMatch := TRUE;
					END_IF
				END_IF
			ELSE
				xDeviceTypeMatch := TRUE;
			END_IF
			
			IF xBusTypeMatch AND xDeviceTypeMatch THEN
				(* loop exits as soon as the n-th bus was found. *)
				uiTmpInstance := uiTmpInstance + 1;
			END_IF	
		END_IF
	UNTIL
		uiTmpInstance = uiInstance OR itfNode = 0
	END_REPEAT
	
	(* bus found? *)
	IF itfBus <> 0 THEN
		(* check if reconfigure is possible *)
		itfReconfigureNode := GetReconfigureProvider(itfBus);
		IF itfReconfigureNode <> 0 THEN
			(* set Enable flag if INode *)
			itfReconfigureNode.Enable := xEnable;
			(* perform reconfigure ==> new Enable flag value will take effect *)
			_itfNodeToReconfigure := itfReconfigureNode;
			_iState := 10;
		ELSE
			(* there is no parent node supporting reconfigure... *)
			ToggleBus := DED.ERROR.NOT_SUPPORTED;
		END_IF
	ELSE
		(* could not find the requested bus *)
		ToggleBus := DED.ERROR.INST_NOT_FOUND;
	END_IF
	
ELSE
	(* device controller is not ready to reconfigure. *)
	ToggleBus := DED.ERROR.OPERATION_INVALID;
END_IF