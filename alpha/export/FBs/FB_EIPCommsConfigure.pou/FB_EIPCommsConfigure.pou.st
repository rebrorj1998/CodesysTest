(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_EIPCommsConfigure
VAR_INPUT
	rootEIPNode : DED.INode;
	enableWord : DWORD;
END_VAR
VAR
	reconfig : DED.Reconfigure;
	testEnable : BOOL;
	
	tempComapareWord : DWORD;
	_recongfigCommand : BOOL;
	state : INT;
END_VAR

VAR_OUTPUT
	
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Program: FB_EIPCommsConfigure
//    Description: Allows configuration of individual EIP in in the device tree (enable/disable) 
//    For example, to turn off the comms to a Keyence BCV if it isn't installed
//    Created by: Ben Hess
//    CretestEnableated Date: Wednesday January 6th, 2021

enableWord.0 := Cube67_BN_E_V2.Enable;
enableWord.1 := FestoManifold.Enable;
enableWord.2 := MSFMotor.Enable;
enableWord.3 := Bag_Delivery_EIP_Motor.Enable;
enableWord.4 := Bag_Delivery_Rear_Motor.Enable;
enableWord.5 := Keyence_BCV.Enable;
enableWord.6 := Infeed_Conveyor_IO.Enable;
enableWord.7 := Panther_PA.Enable;
enableWord.8 := IBD_Motor.Enable;

CASE state OF
	
	0:  reconfig.xExecute := FALSE;
		IF enableWord <> tempComapareWord OR _recongfigCommand THEN
			_recongfigCommand := FALSE;
			tempComapareWord := enableWord;
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