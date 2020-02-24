(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'FBVisuCreator'}
{attribute 'global_init_slot' := '50010'}
VAR_GLOBAL
	iPressureBarExtended : FB_PhysicalDigitalInput(name := 'Pressure Bar Open Prox') := (in := Devices.IOMaster.headIONode.iPort0Pin2);
	iPressureBarRetracted : FB_PhysicalDigitalInput(name := 'Pressure Bar Closed Prox') := (in := Devices.IOMaster.headIONode.iPort0Pin4);
	iPressureBarNotObstructed : FB_PhysicalDigitalInput(name := 'Pressure Bar Not Obstructed Input') := (in := Devices.IOMaster.headIONode.iPort1Pin2);
	iBagPhotoeyeClear : FB_PhysicalDigitalInput(name := 'Bag Edge Photoeye Clear') := (in := Devices.IOMaster.headIONode.iPort1Pin4);
	iBagOpenFingersRightBagPresent : FB_PhysicalDigitalInput(name := 'Right BOF Bag Present') := (in := Devices.IOMaster.headIONode.iPort2Pin2);
	iBagOpenFingersLeftBagPresent : FB_PhysicalDigitalInput(name := 'Left BOF Bag Present') := (in := Devices.IOMaster.headIONode.iPort2Pin4);
	iPowerOnButton : FB_PhysicalDigitalInput(name := 'Power On Button Input') := (in := Devices.IOMaster.headIONode.iPort3Pin2);
	oPowerOnIndication : FB_PhysicalDigitalOutput(name := 'Power On Indication Lamp') := (refOutput := Devices.IOMaster.headIONode.oPort3Pin4);
	//iUnwindBagLevel : FB_PhysicalAnalogInput(name := 'Unwind Bag Level') := (in := Devices.IOMaster.headIONode.iIOLinkPort4);
	iSealBarExtended : FB_PhysicalDigitalInput(name := 'Seal Bar Extended Prox') := (in := Devices.IOMaster.headIONode.iPort5Pin2);
	{warning 'TODO: Seal bar temp is actually iolinkport5 but is faked out for now because of Murr bug'}
	iSealBarTemperature : FB_PhysicalAnalogInput(name := 'Seal Bar Temperature') := (in := Devices.IOMaster.headIONode.iIOLinkPort4, enableLogging := TRUE, logDeadband := 20);
	iMachineInitiateCycle : FB_PhysicalDigitalInput(name := 'Machine Initiate Cycle Input') := (in := Devices.IOMaster.headIONode.iPort6Pin2);
	//iFunnelHighSpeedCounter : FB_PhysicalAnalogInput(name := 'Funnel Parts Count') := (in := Devices.IOMaster.headIONode.iIOLinkPort6);
	iMCROn : FB_PhysicalDigitalInput(name := 'MCR On Input') := (in := Devices.IOMaster.headIONode.iPort7Pin2);
	
	iPrinterDataReady : FB_PhysicalDigitalInput(name := 'Printer Data Ready Signal') := (in := Devices.IOMaster.printerIONode.iX000);
	iPrinterEndOfPrint : FB_PhysicalDigitalInput(name := 'Printer End Print Signal') := (in := Devices.IOMaster.printerIONode.iX001);
	iPrinterServiceRequired : FB_PhysicalDigitalInput(name := 'Printer Service Required Signal') := (in := Devices.IOMaster.printerIONode.iX002);
	iPrinterRibbonOut : FB_PhysicalDigitalInput(name := 'Printer Ribbon Out Signal') := (in := Devices.IOMaster.printerIONode.iX003);
	oPrinterStartPrint : FB_PhysicalDigitalOutput(name := 'Printer Start Print Signal') := (refOutput := Devices.IOMaster.printerIONode.oX100);
	oRunRibbonUnwindMotor : FB_PhysicalDigitalOutput(name := 'Run Ribbon Unwind') := (refOutput := Devices.IOMaster.printerIONode.oX101);;
	
	iFunnelOpened : FB_PhysicalDigitalInput(name := 'Funnel Opened Prox') := (in := Devices.IOMaster.frontGuardIONode.iPort0Pin2);
	iFunnelClosed : FB_PhysicalDigitalInput(name := 'Funnel Closed Prox') := (in := Devices.IOMaster.frontGuardIONode.iPort0Pin4);
	iLDunkLowered : FB_PhysicalDigitalInput(name := 'L-Dunk Lowered Prox') := (in := Devices.IOMaster.frontGuardIONode.iPort1Pin2);
	iLDunkRaised : FB_PhysicalDigitalInput(name := 'L-Dunk Raised Prox') := (in := Devices.IOMaster.frontGuardIONode.iPort1Pin4);
	iAccumFunnelOpened : FB_PhysicalDigitalInput(name := 'Accumulating Funnel Opened') := (in := Devices.IOMaster.frontGuardIONode.iPort2Pin2);
	iAccumFunnelClosed : FB_PhysicalDigitalInput(name := 'Accumulating Funnel Closed') := (in := Devices.IOMaster.frontGuardIONode.iPort2Pin4);
	iPalmButtonRightActive : FB_PhysicalDigitalInput(name := 'Right Palm Button Activated') := (in := Devices.IOMaster.frontGuardIONode.iPort3Pin2);
	iPalmButtonLeftActive : FB_PhysicalDigitalInput(name := 'Left Palm Button Activated') := (in := Devices.IOMaster.frontGuardIONode.iPort3Pin4);
	
	iLoadPlateInLoadingPosition :  FB_PhysicalDigitalInput(name := 'Load Plate in Loading Position Prox') := (in := Devices.IOMaster.dischargeIONode.iPort0Pin2);
	iLoadPlateInDischargePosition : FB_PhysicalDigitalInput(name := 'Load Plate in Discharge Position Prox') := (in := Devices.IOMaster.dischargeIONode.iPort0Pin4);
	iLoadShelfInLoadingPosition : FB_PhysicalDigitalInput(name := 'Load Shelf in Loading Position Prox') := (in := Devices.IOMaster.dischargeIONode.iPort1Pin2);
	iLoadShelfInDischargePosition : FB_PhysicalDigitalInput(name := 'Load Shelf in Loading Position Prox') := (in := Devices.IOMaster.dischargeIONode.iPort1Pin4);
	oExitConveyorRunCommand : FB_PhysicalDigitalOutput(name := 'Exit Conveyor Run Command') := (refOutput := Devices.IOMaster.dischargeIONode.oPort2Pin2);
	iExitConveyorRunningFeedback : FB_PhysicalDigitalInput(name := 'Exit Conveyor Running') := (in := Devices.IOMaster.dischargeIONode.iPort2Pin4);
	iDischargeProductClear : FB_PhysicalDigitalInput(name := 'Product Clear Sensor') := (in := Devices.IOMaster.dischargeIONode.iPort3Pin2);
	oSoftStartEnable : FB_PhysicalDigitalOutput(name := 'Soft Start Enable Solenoid') := (refOutput := Devices.IOMaster.dischargeIONode.oPort4Pin4);
	
	iFillerTrigger : BOOL;
	iFillerOK : BOOL;
	iBaggerInhibit : BOOL;
	oBaggerOK : BOOL;
	oReadyForFiller : BOOL;
	oWaitingForPrinter : BOOL;
	(*
	oExtendPressureBarCylinder : FB_PhysicalDigitalOutput(name := 'Extend Pressure Bar Solenoid') := (refOutput := Devices.valveManifold.oValve0Solenoid0);;
	oRetractPressureBarCylinder : FB_PhysicalDigitalOutput(name := 'Retract Pressure Bar Solenoid') := (refOutput := Devices.valveManifold.oValve0Solenoid1);;
	oRetractLoadPlateCylinder : BOOL;
	oOpenHPAValve : BOOL;
	oOpenLPAValve : BOOL;
	oExtendSealBarCylinder : BOOL;
	oExtendPrintHeadCylinder : BOOL;
	oRotateBOFUp : FB_PhysicalDigitalOutput(name := 'Rotate BOF Up Solenoid') := (refOutput := Devices.valveManifold.oValve3Solenoid0);
	oRotateBOFDown : FB_PhysicalDigitalOutput(name := 'Rotate BOF Down Solenoid') := (refOutput := Devices.valveManifold.oValve3Solenoid1);
	*)
END_VAR