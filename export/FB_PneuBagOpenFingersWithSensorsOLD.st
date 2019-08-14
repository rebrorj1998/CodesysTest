

{attribute 'FBVisuCreator'}
FUNCTION_BLOCK FB_PneuBagOpenFingersWithSensorsOLD EXTENDS FB_BaseBagOpenFingersOLD
VAR_INPUT
	fingerActuators : IUpDown;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	bagMissingLeft : BOOL;
	bagMissingRight : BOOL;
	simBagPresentLeft : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Bag Present Left')) := (minDelay := 20, maxDelay := 30);
	simBagPresentRight : FB_SimulatedFeedbackPhysicalInput(name := CONCAT(_prefix,'Bag Present Right')) := (minDelay := 20, maxDelay := 30);
END_VAR
VAR_IN_OUT
	BagPresentSensorLeft : FB_PhysicalDigitalInput;
	BagPresentSensorRight : FB_PhysicalDigitalInput;
END_VAR

SUPER^();
IF simulateIO THEN
	//RotateDownCMD.simulate := RotateUpCMD.simulate := BagPresentSensorLeft.simulate := BagPresentSensorRight.simulate := TRUE;
	BagPresentSensorLeft.simulate := BagPresentSensorRight.simulate := TRUE;
	EnableSimulation(device := fingerActuators, enableSim := TRUE);
END_IF

simBagPresentLeft(in := fingerActuators.DownAsserted, 
					simFeedbackFault := UN00_Globals.simFaults.failedToGrabBagLeftFinger OR UN00_Globals.simFaults.failedToGrabBagBothFingers, 
					inputToSimulate := BagPresentSensorLeft);
simBagPresentRight(in := fingerActuators.DownAsserted, 
					simFeedbackFault := UN00_Globals.simFaults.failedToGrabBagRightFinger OR UN00_Globals.simFaults.failedToGrabBagBothFingers, 
					inputToSimulate := BagPresentSensorRight);

bagMissingLeft := NOT BagPresentSensorLeft.Active;
bagMissingRight := NOT BagPresentSensorRight.Active;

IF delayToGrab.Q THEN
	fingerActuators.MoveDown();
	_bagMissed := (bagMissingLeft OR bagMissingRight) AND delayToCheckBagPresent.Q;
	_bagGrabbed := (BagPresentSensorLeft.Active AND BagPresentSensorRight.Active) AND delayToCheckBagPresent.Q;
	//_grabBagRequest := FALSE;
END_IF

IF _releaseBagRequest THEN	
	fingerActuators.MoveUp();
	_releaseBagRequest := FALSE;
	_grabBagRequest := FALSE;
END_IF

METHOD RemovePower
VAR_INPUT
END_VAR

SUPER^.RemovePower();

// Try to exhaust the BOF actuators, if the solenoid valve doesn't have that ability then move the fingers up
IF NOT ExhaustIfPossible(fingerActuators) THEN
	fingerActuators.MoveUp();
END_IF