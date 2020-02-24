(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'FBVisuCreator'}
FUNCTION_BLOCK FB_HMIData
VAR_INPUT
	initiateCycle : BOOL;  // Initiate Cycle Pushbutton
	ackAllFaults : BOOL; // Acknowledge All Faults from HMI
	makeReady : BOOL;
	pressureBarService : ServiceCommands;
	loadPlateService : ServiceCommands;
    stopMachine : BOOL;
	{attribute 'FBVisuCreatorFormatString' := '%s'}
	version : STRING := '0.2A';
	inCycle : BOOL;
	batchEnable : BOOL;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	batchSetting : UDINT := 10;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	batchCount : UDINT;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	headCycleCount : UDINT;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	pressureBarOpenDelay : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	pressureBarCloseDelay : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	passthroughSetting : REAL := 8.0;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	passthroughActual : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	lpaDwell : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	hpaDwell : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	sealBarDwell : REAL := 0.750;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	sealBarTemperatureSetting : UDINT;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	sealBarTemperature : UDINT;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	sealFlattenerBagOpenPositionSetting : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	sealFlattenerFlattenedPositionSetting : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	sealFlattenerMoveInPositionSetting : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	bagSkirtLength : REAL := 1.35;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	bagLength : REAL := 23.5;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	bagWidth : REAL := 17.5;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	bagThickness : REAL := 2.5;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	bagForwardSpeed : UDINT := 55;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	bagReverseSpeed : UDINT := 3;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	printSpeed : UDINT := 6;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	printLength : REAL := 8.0;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	printOffset : REAL := 2.0;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	fillerCountSetting : UDINT;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	fillerCurrentCount : UDINT;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	fillerDropTime : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	loadPlateDelay : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	loadPlateDwell : REAL := 2.5;
	exitConveyorService: ServiceCommands;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	exitConveyorDwell : REAL := 9.0;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	lastCycleTime : REAL;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	bagDropClearanceDwell : REAL := 0.5;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	averageCycleTime : REAL;
	resetAverageCycleTime : BOOL;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	bagOpenRetrySetting : UINT := 3;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	bagOpenRetryCount : UINT;
	{attribute 'FBVisuCreatorFormatString' := '%d'}
	currentJobID : INT;
	separateBeforeSeal : BOOL := TRUE;
	activateDemoMode : BOOL;
	bagOpenAssistEnable : BOOL := TRUE;
	bagOpenSensorEnable : BOOL := TRUE;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	grabBagDelay : REAL := 0.5;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	checkForBagOpenDelay : REAL := 1.0;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	bagClearedFromFingersDelay : REAL := 0.5;
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	vacuumDwell : REAL := 0.5;
	(*Faults*)
	{attribute 'FBVisuCreatorFormatString' := '%s'}
	pressureBarState : STRING;
    stationValveSelection : ARRAY[1..16] OF ValveSelection := 	[ValveSelection.PressureBar,
																ValveSelection.PressureBar,
																ValveSelection.SealBar,
																ValveSelection.HPA_LPA,
																ValveSelection.LoadPlate,
																ValveSelection.BagOpenFingers,
																ValveSelection.PrintHead,
																ValveSelection.Vacuum,
																ValveSelection.SealFlattenersVerticalAxis,
																ValveSelection.LoadShelf,
																6(ValveSelection.Blank)];
    (*Counters*)
    //baggerCycles : FB_MachineCounter(name := 'Bagger Cycle Counter');
	pressureBarCycles : FB_MachineCounter(name := 'Pressure Bar Cycle Counter');
	//passthroughChanges : FB_MachineCounter(name := 'Passthrough Changes Counter');
	//loadPlateCycles : FB_MachineCounter(name := 'Load Plate Cycle Counter');
	//printerCycles : FB_MachineCounter(name := 'Printer Cycle Counter');
	//motorizedSealFlattenerCycles : FB_MachineCounter(name := 'Motorized Seal Flattener Cycles');
	//bagOpenRetryTotal : FB_MachineCounter(name := 'Bag Open Retry Totals');
	(*Info*)
	faultActive : BOOL;
	simulateAllIO : BOOL;
	
	(*Factoy Config*)
	bofSelection : BagOpenFingersSelection := BagOpenFingersSelection.PneumaticWithBagOpenSensors;
	bofEnable : BOOL := TRUE;
	sealFlattenersSelection : SealFlattenerSelection := SealFlattenerSelection.MotorizedSealFlatteners;
	sealFlattenersEnable : BOOL := TRUE;
	printerSelection : LabelPrinterSelection := LabelPrinterSelection.ZebraPrinter;
	printerEnable : BOOL := TRUE;
	integratedExitConveyorSelection : IntegratedConveyorSelection := IntegratedConveyorSelection.RearExit;
	integratedExitConveyorEnable : BOOL := TRUE;
	packageEjectSelection : PackageEjectionSelection := PackageEjectionSelection.RearRetractingLoadPlate;
	packageEjectEnable : BOOL := TRUE;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
