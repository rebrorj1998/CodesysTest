(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM Main_PRG
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

END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{IF defined (IsSimulationMode)}
	HMIData.simulateAllIO := TRUE;
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

CASE HMIData.bofSelection OF
	BagOpenFingersSelection.NotInstalled: 					
															activeBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
															activeBagOpenFingers.OptionInstalled := FALSE;
	
	BagOpenFingersSelection.PneumaticWithBagOpenSensors: 	activeBagOpenFingers := machineComponents.standardBagOpenFingersWithSensors;
															activeBagOpenFingers.OptionInstalled := TRUE;
															activeBagOpenFingers.OptionEnabled := HMIData.bofEnable;
END_CASE

CASE HMIData.sealFlattenersSelection OF
	SealFlattenerSelection.NotInstalled:					activeSealFlatteners := machineComponents.motorizedSealFlatteners;
															activeSealFlatteners.OptionInstalled := FALSE;
	
	SealFlattenerSelection.MotorizedSealFlatteners:			activeSealFlatteners := machineComponents.motorizedSealFlatteners;
															activeSealFlatteners.OptionInstalled := TRUE;
															activeSealFlatteners.OptionEnabled := HMIData.sealFlattenersEnable;
END_CASE

CASE HMIData.printerSelection OF
	LabelPrinterSelection.NotInstalled:						activePrinter := machineComponents.labelPrinter;
															activePrinter.OptionInstalled := FALSE;
	
	LabelPrinterSelection.ZebraPrinter:						activePrinter := machineComponents.labelPrinter;
															activePrinter.OptionInstalled := TRUE;
															activePrinter.OptionEnabled := HMIData.printerEnable;
END_CASE

EM01_Pro18BaggerHead(
	bagOpenFingers:= activeBagOpenFingers, 
	sealFlatteners:= activeSealFlatteners, 
	sealer:= machineComponents.standardSealBar, 
	pressureBar:= machineComponents.pneumaticPressureBar, 
	printer:= activePrinter, 
	bagDelivery:= machineComponents.bagDelivery, 
	vacuumBagOpen:= machineComponents.vacuumCups, 
	bagOpenAssistEnabled:= HMIData.bagOpenAssistEnable, 
	bagOpenSensorEnabled:= HMIData.bagOpenSensorEnable,
	separateBeforeSealEnabled:= HMIData.separateBeforeSeal,
	bagOpenRetrySetting:= HMIData.bagOpenRetrySetting,
	vacuumDwell := TO_TIME(HMIData.vacuumDwell * 1000), 
	baggerCycleActive=> ,
	bagOpenRetryCount=> HMIData.bagOpenRetryCount);
	
	
activeBaggerHead REF= EM01_Pro18BaggerHead;	
UN00_Pro18Machine(
	faultActive := HMIData.faultActive,
	baggerHead := activeBaggerHead,
	discharge := EM02_Pro18Discharge);
	
Globals.SystemLog();

IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := Globals.SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF


HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;
IF HMIData.ackAllFaults THEN
	GlobalObjects.CollectionOfActiveFaults.AckAll();
	HMIData.ackAllFaults := FALSE;
END_IF

IF HMIData.initiateCycle THEN
	IF UN00_Pro18Machine.currentState = PACK_ML.State.Execute THEN
		activeBaggerHead.StartCycle();
	END_IF
	HMIData.initiateCycle := FALSE;
END_IF

IF firstScanDone THEN
	GlobalObjects.CollectionOfExecutable.ExecuteAll();
END_IF
