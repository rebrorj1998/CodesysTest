(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION CheckIfReady : BOOL
VAR_INPUT
	Component : IComponent;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function: CheckIfReady()
//	Description: Helper function
//				 Pass in a component - if it has a homable motor, and is not yet homed, start homing
//	Created by: Ben Hess
//	Created Date: June 13th, 2020

IF Component.Ready OR NOT Component.OptionActive THEN
	CheckIfReady := TRUE;
ELSE
	RETURN;
END_IF
