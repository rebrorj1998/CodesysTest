(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'analysis' := '-169, -34'}FUNCTION_BLOCK FB_DeviceTreeEnable
VAR_INPUT
	rootEIPNode : DED.INode;
	rootModbusTCPNode : DED.INode;
END_VAR
VAR
	reconfigEIP : DED.Reconfigure;
	reconfigModbusTCP : DED.Reconfigure;
	deviceState : DED.DEVICE_STATE;
	_recongfigCommand : BOOL;
	state : INT;
	disabledSettingWordEIP : DWORD;
	disabledStatusWordEIP : DWORD;
	disabledSettingWordModbusTCP : DWORD;
	disabledStatusWordModbusTCP : DWORD;
END_VAR

VAR_OUTPUT
	
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Program: FB_EIPCommsConfigure
//    Description: Allows configuration of individual EIP in in the device tree (enable/disable) 
//    For example, to turn off the comms to a Keyence BCV if it isn't installed
//    Created by: Ben Hess
//    Created Date: Wednesday January 6th, 2021

//  Get enable status property
disabledSettingWordEIP.0 := NOT Cube67_BN_E_V2.Enable;
disabledSettingWordEIP.1 := NOT FestoManifold.Enable;
disabledSettingWordEIP.2 := NOT MSFMotor.Enable;
disabledSettingWordEIP.3 := NOT Bag_Delivery_EIP_Motor.Enable;
disabledSettingWordEIP.4 := NOT Bag_Delivery_Rear_Motor.Enable;
disabledSettingWordEIP.5 := NOT Keyence_BCV.Enable;
disabledSettingWordEIP.6 := NOT Infeed_Conveyor_IO.Enable;
disabledSettingWordEIP.7 := NOT Panther_PA.Enable;
disabledSettingWordEIP.8 := NOT IBD_Motor.Enable;
disabledSettingWordEIP.9 := NOT DM374_BCV.Enable;

disabledSettingWordModbusTCP.0 := NOT ModbusTCP_Slave_Device.Enable;

// Get actual enabled state
deviceState := Cube67_BN_E_V2.GetDeviceState();
disabledStatusWordEIP.0 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := FestoManifold.GetDeviceState();
disabledStatusWordEIP.1 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := MSFMotor.GetDeviceState();
disabledStatusWordEIP.2 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Bag_Delivery_EIP_Motor.GetDeviceState();
disabledStatusWordEIP.3 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Bag_Delivery_Rear_Motor.GetDeviceState();
disabledStatusWordEIP.4 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Keyence_BCV.GetDeviceState();
disabledStatusWordEIP.5 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Infeed_Conveyor_IO.GetDeviceState();
disabledStatusWordEIP.6 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Panther_PA.GetDeviceState();
disabledStatusWordEIP.7 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := IBD_Motor.GetDeviceState();
disabledStatusWordEIP.8 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := DM374_BCV.GetDeviceState();
disabledStatusWordEIP.9 := deviceState = DED.DEVICE_STATE.DISABLED;

deviceState := ModbusTCP_Slave_Device.GetDeviceState();
disabledStatusWordModbusTCP.0 := deviceState = DED.DEVICE_STATE.DISABLED;

// Compare desired status against state - if different do a reconfigure.
CASE state OF
	0:  reconfigEIP.xExecute := reconfigModbusTCP.xExecute := FALSE;
		IF (disabledSettingWordEIP <> disabledStatusWordEIP) 
		OR (disabledSettingWordModbusTCP <> disabledStatusWordModbusTCP)
		OR _recongfigCommand THEN
			state := 10;
		END_IF
	
	10:	// Set appropriate reconfig - don't want to reset EIP comms if changing Modbus and vice versa
		IF (disabledSettingWordEIP <> disabledStatusWordEIP) OR _recongfigCommand THEN 
			reconfigEIP.xExecute := TRUE;
		END_IF
		IF (disabledSettingWordModbusTCP <> disabledStatusWordModbusTCP) OR _recongfigCommand THEN 
			reconfigModbusTCP.xExecute := TRUE;
		END_IF
		_recongfigCommand := FALSE;
		state := 11;
	
	11:	
		IF (reconfigEIP.xDone OR reconfigModbusTCP.xDone) 
			OR (reconfigEIP.xError OR reconfigModbusTCP.xError) THEN
				state := 0;
		END_IF
END_CASE




reconfigEIP(
	xExecute:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	itfNode:= rootEIPNode, 
	eError=> );

reconfigModbusTCP(
	xExecute:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	itfNode:= rootModbusTCPNode, 
	eError=> );