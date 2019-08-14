

PROGRAM PLC_PRG
VAR

	firstScanDone : BOOL;
	UN00_Pro18Machine : FB_UN00_SharpMachine(name := 'UN00 - Sharp Pro-18');
	EM01_Pro18BaggerHead : EM01_BaggerHead(name := 'EM01 - Pro 18 Bagger Head');
	EM02_Pro18Discharge : EM02_Discharge(name := 'EM02 - Pro 18 Discharge');
	activeBaggerHead : REFERENCE TO EM01_BaggerHead;
	machineComponents : EM01_Bagger_Control_Modules();
	

	
	activeBagOpenFingers : IBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
	activeSealFlatteners : ISealFlatteners;
	activePressureBar : IPressureBar;
	activeSealer : ISealer;
	activePrinter : IPrinter;
	activeBagDelivery : IBagDelivery;
	activeRetractingLoadPlate : IRetractingLoadPlate;
	activeExitConveyor : IExitConveyor;
	activeVacuumBagOpen : IVacuumBagOpen;
	
	powerUpPassthroughMotor : Sharp_Motion.MC_Power;
	powerUpMSFHorizMotor : Sharp_Motion.MC_Power;
	powerUpBagDeliveryMotor : Sharp_Motion.MC_Power;

END_VAR
{IF defined (IsSimulationMode)}
	HMI.data.simulateAllIO := TRUE;
{END_IF}

Devices();
machineComponents();

powerUpPassthroughMotor(Enable := TRUE, Axis := machineComponents.passthroughMotor);
powerUpPassthroughMotor.DriveStart := TRUE;
powerUpPassthroughMotor.RegulatorOn := TRUE;

powerUpMSFHorizMotor(Enable := TRUE, Axis := machineComponents.msfHorizontalMotor);
powerUpMSFHorizMotor.DriveStart := TRUE;
powerUpMSFHorizMotor.RegulatorOn := TRUE;

powerUpBagDeliveryMotor(Enable := TRUE, Axis := machineComponents.bagDeliveryFrontMotor);
powerUpBagDeliveryMotor.DriveStart := TRUE;
powerUpBagDeliveryMotor.RegulatorOn := TRUE;

CASE HMI.data.bofSelection OF
	BagOpenFingersSelection.NotInstalled: 					
															activeBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
															activeBagOpenFingers.OptionInstalled := FALSE;
	
	BagOpenFingersSelection.PneumaticWithBagOpenSensors: 	activeBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
															activeBagOpenFingers.OptionInstalled := TRUE;
															activeBagOpenFingers.OptionEnabled := HMI.data.bofEnable;
END_CASE

CASE HMI.data.sealFlattenersSelection OF
	SealFlattenerSelection.NotInstalled:					activeSealFlatteners := machineComponents.motorizedSealFlatteners;
															activeSealFlatteners.OptionInstalled := FALSE;
	
	SealFlattenerSelection.MotorizedSealFlatteners:			activeSealFlatteners := machineComponents.motorizedSealFlatteners;
															activeSealFlatteners.OptionInstalled := TRUE;
															activeSealFlatteners.OptionEnabled := HMI.data.sealFlattenersEnable;
END_CASE

CASE HMI.data.printerSelection OF
	LabelPrinterSelection.NotInstalled:						activePrinter := machineComponents.labelPrinter;
															activePrinter.OptionInstalled := FALSE;
	
	LabelPrinterSelection.ZebraPrinter:						activePrinter := machineComponents.labelPrinter;
															activePrinter.OptionInstalled := TRUE;
															activePrinter.OptionEnabled := HMI.data.printerEnable;
END_CASE

EM01_Pro18BaggerHead(
	bagOpenFingers:= activeBagOpenFingers, 
	sealFlatteners:= activeSealFlatteners, 
	sealer:= machineComponents.standardSealBar, 
	pressureBar:= machineComponents.pneumaticPressureBar, 
	printer:= activePrinter, 
	bagDelivery:= machineComponents.bagDelivery, 
	vacuumBagOpen:= machineComponents.vacuumCups, 
	bagOpenAssistEnabled:= HMI.data.bagOpenAssistEnable, 
	bagOpenSensorEnabled:= HMI.data.bagOpenSensorEnable,
	separateBeforeSealEnabled:= HMI.data.separateBeforeSeal,
	bagOpenRetrySetting:= HMI.data.bagOpenRetrySetting,
	vacuumDwell := TO_TIME(HMI.data.vacuumDwell * 1000), 
	baggerCycleActive=> ,
	bagOpenRetryCount=> HMI.data.bagOpenRetryCount);
	
	
activeBaggerHead REF= EM01_Pro18BaggerHead;	
UN00_Pro18Machine(
	faultActive := HMI.data.faultActive,
	baggerHead := activeBaggerHead,
	discharge := EM02_Pro18Discharge);
	
Globals.SystemLog();

IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := Globals.SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF


HMI.data.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;
IF HMI.data.ackAllFaults THEN
	GlobalObjects.CollectionOfActiveFaults.AckAll();
	HMI.data.ackAllFaults := FALSE;
END_IF

IF HMI.data.initiateCycle THEN
	IF UN00_Pro18Machine.currentState = PACK_ML.State.Execute THEN	
		activeBaggerHead.StartCycle();
	END_IF
	HMI.data.initiateCycle := FALSE;
END_IF

IF firstScanDone THEN
	GlobalObjects.CollectionOfExecutable.ExecuteAll();
END_IF


PROGRAM PLC_PRG
VAR
	firstScan : BOOL; //First Scan Bit
	firstScanDone : BOOL; //First Scan Bit
	SystemLog : FB_InternalLogger;
END_VAR

SystemLog();

IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF

PROGRAM PLC_PRG
VAR

	firstScanDone : BOOL;
	UN00_Pro18Machine : FB_UN00_SharpMachine(name := 'UN00 - Sharp Pro-18');
	EM01_Pro18BaggerHead : EM01_BaggerHead(name := 'EM01 - Pro 18 Bagger Head');
	EM02_Pro18Discharge : EM02_Discharge(name := 'EM02 - Pro 18 Discharge');
	activeBaggerHead : REFERENCE TO EM01_BaggerHead;
	machineComponents : EM01_Bagger_Control_Modules();
	

	
	activeBagOpenFingers : IBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
	activeSealFlatteners : ISealFlatteners;
	activePressureBar : IPressureBar;
	activeSealer : ISealer;
	activePrinter : IPrinter;
	activeBagDelivery : IBagDelivery;
	activeRetractingLoadPlate : IRetractingLoadPlate;
	activeExitConveyor : IExitConveyor;
	activeVacuumBagOpen : IVacuumBagOpen;
	
	powerUpPassthroughMotor : Sharp_Motion.MC_Power;
	powerUpMSFHorizMotor : Sharp_Motion.MC_Power;
	powerUpBagDeliveryMotor : Sharp_Motion.MC_Power;

END_VAR
{IF defined (IsSimulationMode)}
	HMI.data.simulateAllIO := TRUE;
{END_IF}

Devices();
machineComponents();

powerUpPassthroughMotor(Enable := TRUE, Axis := machineComponents.passthroughMotor);
powerUpPassthroughMotor.DriveStart := TRUE;
powerUpPassthroughMotor.RegulatorOn := TRUE;

powerUpMSFHorizMotor(Enable := TRUE, Axis := machineComponents.msfHorizontalMotor);
powerUpMSFHorizMotor.DriveStart := TRUE;
powerUpMSFHorizMotor.RegulatorOn := TRUE;

powerUpBagDeliveryMotor(Enable := TRUE, Axis := machineComponents.bagDeliveryFrontMotor);
powerUpBagDeliveryMotor.DriveStart := TRUE;
powerUpBagDeliveryMotor.RegulatorOn := TRUE;

CASE HMI.data.bofSelection OF
	BagOpenFingersSelection.NotInstalled: 					
															activeBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
															activeBagOpenFingers.OptionInstalled := FALSE;
	
	BagOpenFingersSelection.PneumaticWithBagOpenSensors: 	activeBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
															activeBagOpenFingers.OptionInstalled := TRUE;
															activeBagOpenFingers.OptionEnabled := HMI.data.bofEnable;
END_CASE

CASE HMI.data.sealFlattenersSelection OF
	SealFlattenerSelection.NotInstalled:					activeSealFlatteners := machineComponents.motorizedSealFlatteners;
															activeSealFlatteners.OptionInstalled := FALSE;
	
	SealFlattenerSelection.MotorizedSealFlatteners:			activeSealFlatteners := machineComponents.motorizedSealFlatteners;
															activeSealFlatteners.OptionInstalled := TRUE;
															activeSealFlatteners.OptionEnabled := HMI.data.sealFlattenersEnable;
END_CASE

CASE HMI.data.printerSelection OF
	LabelPrinterSelection.NotInstalled:						activePrinter := machineComponents.labelPrinter;
															activePrinter.OptionInstalled := FALSE;
	
	LabelPrinterSelection.ZebraPrinter:						activePrinter := machineComponents.labelPrinter;
															activePrinter.OptionInstalled := TRUE;
															activePrinter.OptionEnabled := HMI.data.printerEnable;
END_CASE

EM01_Pro18BaggerHead(
	bagOpenFingers:= activeBagOpenFingers, 
	sealFlatteners:= activeSealFlatteners, 
	sealer:= machineComponents.standardSealBar, 
	pressureBar:= machineComponents.pneumaticPressureBar, 
	printer:= activePrinter, 
	bagDelivery:= machineComponents.bagDelivery, 
	vacuumBagOpen:= machineComponents.vacuumCups, 
	bagOpenAssistEnabled:= HMI.data.bagOpenAssistEnable, 
	bagOpenSensorEnabled:= HMI.data.bagOpenSensorEnable,
	separateBeforeSealEnabled:= HMI.data.separateBeforeSeal,
	bagOpenRetrySetting:= HMI.data.bagOpenRetrySetting,
	vacuumDwell := TO_TIME(HMI.data.vacuumDwell * 1000), 
	baggerCycleActive=> ,
	bagOpenRetryCount=> HMI.data.bagOpenRetryCount);
	
	
activeBaggerHead REF= EM01_Pro18BaggerHead;	
UN00_Pro18Machine(
	faultActive := HMI.data.faultActive,
	baggerHead := activeBaggerHead,
	discharge := EM02_Pro18Discharge);
	
Globals.SystemLog();

IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := Globals.SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF


HMI.data.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;
IF HMI.data.ackAllFaults THEN
	GlobalObjects.CollectionOfActiveFaults.AckAll();
	HMI.data.ackAllFaults := FALSE;
END_IF

IF HMI.data.initiateCycle THEN
	IF UN00_Pro18Machine.currentState = PACK_ML.State.Execute THEN	
		activeBaggerHead.StartCycle();
	END_IF
	HMI.data.initiateCycle := FALSE;
END_IF

IF firstScanDone THEN
	GlobalObjects.CollectionOfExecutable.ExecuteAll();
END_IF


PROGRAM PLC_PRG
VAR
	firstScan : BOOL; //First Scan Bit
	firstScanDone : BOOL; //First Scan Bit
	SystemLog : FB_InternalLogger;
END_VAR

SystemLog();

IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF