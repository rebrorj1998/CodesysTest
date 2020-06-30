(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION CheckIfHomed : BOOL
VAR_INPUT
	Component : IComponent;
END_VAR
VAR
	homableDevice : IHomable;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function: CheckIfHomed()
//	Description: Helper function
//				 Pass in a component - if it has a homable motor, and is not yet homed, start homing
//	Created by: Ben Hess
//	Created Date: May 16th, 2019

IF (__QUERYINTERFACE(Component, homableDevice)) THEN
	IF homableDevice.IsHomed OR NOT Component.OptionActive THEN
		CheckIfHomed := TRUE;
	ELSE 
		RETURN;
	END_IF
ELSE
	CheckIfHomed := TRUE;
END_IF