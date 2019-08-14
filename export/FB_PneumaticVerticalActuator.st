

FUNCTION_BLOCK FB_PneumaticVerticalActuator EXTENDS FB_PneumaticActuator IMPLEMENTS IUpDown
VAR_INPUT
	cylinder : ICylinder;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
VAR_IN_OUT	
END_VAR

//	Function Block: FB_PneumaticVerticalActuator
//	Description: Wrapper for a cylinder with Up/Down substitiuted for Extend/Retract
//				  
//
//	Usage: 
// 
//	Created by: Ben Hess
//	Created Date: 6-27-2019

EnableSimulation(cylinder, _simulateActive);


PROPERTY UpAsserted : BOOL


PROPERTY DownAsserted : BOOL


PROPERTY IsDown : BOOL


PROPERTY IsUp : BOOL


METHOD MoveDown

cylinder.Extend();

METHOD MoveUp

cylinder.Retract();

FUNCTION_BLOCK FB_PneumaticVerticalActuator EXTENDS FB_PneumaticActuator IMPLEMENTS IUpDown
VAR_INPUT
	cylinder : ICylinder;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
VAR_IN_OUT	
END_VAR

//	Function Block: FB_PneumaticVerticalActuator
//	Description: Wrapper for a cylinder with Up/Down substitiuted for Extend/Retract
//				  
//
//	Usage: 
// 
//	Created by: Ben Hess
//	Created Date: 6-27-2019

EnableSimulation(cylinder, _simulateActive);


PROPERTY UpAsserted : BOOL


PROPERTY DownAsserted : BOOL


PROPERTY IsDown : BOOL


PROPERTY IsUp : BOOL


METHOD MoveDown

cylinder.Extend();

METHOD MoveUp

cylinder.Retract();