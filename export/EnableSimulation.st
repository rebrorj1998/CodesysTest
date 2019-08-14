

FUNCTION EnableSimulation : BOOL
VAR_INPUT
	device : IAllObjects;
	enableSim : BOOL;
END_VAR
VAR
	simulatable : ISimulateable;
END_VAR

//	Function: EnableSimulation()
//	Description: Helper function
//				 Pass in a device. Set simulation status if possible
//	Created by: Ben Hess
//	Created Date: June 25th, 2019

IF (__QUERYINTERFACE(device, simulatable)) THEN
	simulatable.Simulate := enableSim;
END_IF