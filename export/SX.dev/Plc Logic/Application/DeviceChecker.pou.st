(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK DeviceChecker
VAR_INPUT
END_VAR
VAR_OUTPUT
	uiNodes			: UINT;		// number of nodes in device tree
	uiUnknown		: UINT;		// number of devices in unkown state
	uiStopped		: UINT;		// number of devices in stopped state
	uiRunning		: UINT;		// number of devices in running state
	uiError			: UINT;		// number of devices in error state
	uiNotConfigured : UINT;		// number of devices in not configured state
	uiNotFound		: UINT;		// number of devices in not found state
	uiDisabled		: UINT;		// number of disabled devices
END_VAR
VAR
	_itfCurrentNotRunning	: DED.INode;
	_itfNode				: DED.INode;
	_itfDevice				: DED.IDevice;
	_itfBus					: DED.IBus;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
uiNodes			:= 0;
uiUnknown		:= 0;
uiStopped		:= 0;
uiRunning		:= 0;
uiError			:= 0;
uiNotConfigured := 0;
uiNotFound		:= 0;
uiDisabled		:= 0;

// GetRoot() returns INode of the PLC
_itfNode := DED.GetRoot();

REPEAT
	(* cast INode to IDevice *)
	_itfDevice := DED.INode_TO_IDevice(_itfNode);
	(* always check if casting this node was successful!!! *)
	IF _itfDevice <> 0 THEN
	
		CASE _itfDevice.GetDeviceState() OF
		DED.DEVICE_STATE.UNKNOWN:
			uiUnknown := uiUnknown + 1;
		DED.DEVICE_STATE.STOPPED:
			uiStopped := uiStopped + 1;
		DED.DEVICE_STATE.RUNNING:
			uiRunning := uiRunning + 1;
		DED.DEVICE_STATE.ERROR:
			uiError := uiError + 1;
		DED.DEVICE_STATE.NOT_CONFIGURED:
			uiNotConfigured := uiNotConfigured + 1;
		DED.DEVICE_STATE.NOT_FOUND:
			uiNotFound := uiNotFound + 1;
		DED.DEVICE_STATE.DISABLED:
			uiDisabled := uiDisabled + 1;
		END_CASE
		
	ELSE
		(* the current node is not an IDevice. Try to cast it to IBus (e.g. CANbus does not implement IDevice, but IBus ) *)
		_itfBus := DED.INode_TO_IBus(_itfNode);
		IF _itfBus <> 0 THEN
			CASE _itfBus.GetBusState() OF
			DED.BUS_STATE.DISABLED:
				uiDisabled := uiDisabled + 1;
			DED.BUS_STATE.ERROR:
				uiError := uiError + 1;
			DED.BUS_STATE.RUNNING:
				uiRunning := uiRunning + 1;
			DED.BUS_STATE.STOPPED:
				uiStopped := uiStopped + 1;
			DED.BUS_STATE.UNKNOWN:
				uiUnknown := uiUnknown + 1;
			END_CASE
		END_IF
	
	END_IF
	
	(* total node count *)
	uiNodes := uiNodes + 1;
	
	(* get the next node from depth-first search*)
	_itfNode := DED.GetNextNode(_itfNode);
UNTIL
	_itfNode = 0
END_REPEAT