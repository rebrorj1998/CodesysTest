

FUNCTION HomeIfNeeded : BOOL
VAR_INPUT
	Component : IComponent;
END_VAR
VAR
	homableDevice : IHomable;
END_VAR

//	Function: HomeIfNeeded()
//	Description: Helper function
//				 Pass in a component - if it has a homable motor, and is not yet homed, start homing
//	Created by: Ben Hess
//	Created Date: May 16th, 2019

IF (__QUERYINTERFACE(Component, homableDevice)) AND Component.OptionActive THEN
	IF homableDevice.IsHomed THEN
		HomeIfNeeded := TRUE;
		RETURN;
	ELSE
		homableDevice.HomeNow();
	END_IF
END_IF

FUNCTION HomeIfNeeded : BOOL
VAR_INPUT
	Component : IComponent;
END_VAR
VAR
	homableDevice : IHomable;
END_VAR

//	Function: HomeIfNeeded()
//	Description: Helper function
//				 Pass in a component - if it has a homable motor, and is not yet homed, start homing
//	Created by: Ben Hess
//	Created Date: May 16th, 2019

IF (__QUERYINTERFACE(Component, homableDevice)) AND Component.OptionActive THEN
	IF homableDevice.IsHomed THEN
		HomeIfNeeded := TRUE;
		RETURN;
	ELSE
		homableDevice.HomeNow();
	END_IF
END_IF