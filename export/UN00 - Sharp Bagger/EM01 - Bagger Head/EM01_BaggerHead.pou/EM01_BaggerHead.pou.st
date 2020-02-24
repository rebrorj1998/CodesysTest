(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_BaggerHead EXTENDS FB_PackMLStates IMPLEMENTS IEM01_BaggerHead
VAR_INPUT 
	(*Comnponents*)
	bagOpenFingers : IBagOpenFingers;
	sealFlatteners : ISealFlatteners;
	sealer : ISealer;
	pressureBar : IPressureBar;
	printer : IPrinter;
	bagDelivery : IBagDelivery;
	vacuumBagOpen : IVacuumBagOpen;
	
	(*Options and settings*)
	bagOpenAssistEnabled : BOOL;		// Bag Open Assist Option Enabled from HMI
	bagOpenSensorEnabled : BOOL;		// Bag Open Sensors Enabled from HMI
	separateBeforeSealEnabled : BOOL;	// Separate before Seal Option Enabled from HMI
	bagOpenRetrySetting : UINT;
	newJobLoaded : BOOL;
	vacuumDwell : TIME;
END_VAR
VAR_OUTPUT
	baggerCycleActive : BOOL;
	bagOpenRetryCount : UINT;
	failedToOpenBag : FB_Fault(name := CONCAT(_prefix,'Failed to Open Bag'));
END_VAR
VAR
	_startCycle : BOOL;
	_readyToAcceptProduct : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
