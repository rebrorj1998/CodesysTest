(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_EIPCommsConfigure
VAR_INPUT
	rootEIPNode : DED.INode;
	
END_VAR
VAR
	reconfig : DED.Reconfigure;
	deviceState : DED.DEVICE_STATE;
	tempComapareWord : DWORD;
	_recongfigCommand : BOOL;
	state : INT;
	disabledSettingWord : DWORD;
	disabledStatusWord : DWORD;
END_VAR

VAR_OUTPUT
	
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Program: FB_EIPCommsConfigure
//    Description: Allows configuration of individual EIP in in the device tree (enable/disable) 
//    For example, to turn off the comms to a Keyence BCV if it isn't installed
//    Created by: Ben Hess
//    Created Date: Wednesday January 6th, 2021

disabledSettingWord.0 := NOT Cube67_BN_E_V2.Enable;
disabledSettingWord.1 := NOT FestoManifold.Enable;
disabledSettingWord.2 := NOT MSFMotor.Enable;
disabledSettingWord.3 := NOT Bag_Delivery_EIP_Motor.Enable;
disabledSettingWord.4 := NOT Bag_Delivery_Rear_Motor.Enable;
disabledSettingWord.5 := NOT Keyence_BCV.Enable;
disabledSettingWord.6 := NOT Infeed_Conveyor_IO.Enable;
disabledSettingWord.7 := NOT Panther_PA.Enable;
disabledSettingWord.8 := NOT IBD_Motor.Enable;
disabledSettingWord.9 := NOT DM374_BCV.Enable;

deviceState := Cube67_BN_E_V2.GetDeviceState();
disabledStatusWord.0 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := FestoManifold.GetDeviceState();
disabledStatusWord.1 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := MSFMotor.GetDeviceState();
disabledStatusWord.2 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Bag_Delivery_EIP_Motor.GetDeviceState();
disabledStatusWord.3 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Bag_Delivery_Rear_Motor.GetDeviceState();
disabledStatusWord.4 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Keyence_BCV.GetDeviceState();
disabledStatusWord.5 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Infeed_Conveyor_IO.GetDeviceState();
disabledStatusWord.6 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := Panther_PA.GetDeviceState();
disabledStatusWord.7 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := IBD_Motor.GetDeviceState();
disabledStatusWord.8 := deviceState = DED.DEVICE_STATE.DISABLED;
deviceState := DM374_BCV.GetDeviceState();
disabledStatusWord.9 := deviceState = DED.DEVICE_STATE.DISABLED;

CASE state OF
	0:  reconfig.xExecute := FALSE;
		IF disabledSettingWord <> disabledStatusWord OR _recongfigCommand THEN
			_recongfigCommand := FALSE;
			state := 10;
		END_IF
	
	10:	reconfig.xExecute := TRUE;
		state := 11;
	
	11:	
		IF reconfig.xDone OR reconfig.xError THEN
			state := 0;
		END_IF
	
	
END_CASE




reconfig(
	xExecute:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	itfNode:= rootEIPNode, 
	eError=> );