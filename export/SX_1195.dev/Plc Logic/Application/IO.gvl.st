(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '50010'}
VAR_GLOBAL
	iptJawNotObstructed : FB_PhysicalDigitalInput(name := 'Jaw Not Obstructed') := (in := iJawNotObstructed);
	iptPrinterDataReady : FB_PhysicalDigitalInput(name := 'Printer Data Ready') := (in := iPrinterDataReady);
	iptPrinterBusy : FB_PhysicalDigitalInput(name := 'Printer Busy') := (in := iPrinterBusy);
	iptBagEdgePhotoeye : FB_PhysicalDigitalInput(name := 'Bag Edge Photoeye') := (in := iBagEdgePhotoeye);
	iptCycleStart : FB_PhysicalDigitalInput(name := 'Cycle Start') := (in := iCycleStart);
	iptPrintHeadLowered : FB_PhysicalDigitalInput(name := 'Printhead Lowered') := (in := iPrintHeadLowered);
	iptJawClosed : FB_PhysicalDigitalInput(name := 'Jaw Closed') := (in := iJawClosed);
	iptJawNearClosed : FB_PhysicalDigitalInput(name := 'Jaw Near Closed') := (in := iJawNearClosed);
	iptBarcodeOK : FB_PhysicalDigitalInput(name := 'Barcode OK') := (in := iBarcodeOK);
	iptBarcodeNG : FB_PhysicalDigitalInput(name := 'Barcode NG') := (in := iBarcodeNG);
	iptLightCurtain : FB_PhysicalDigitalInput(name := 'Light Curtain Clear') := (in := iLightCurtain);
	iptFillerTrigger : FB_PhysicalDigitalInput(name := 'Filler Trigger') := (in := iFillerTrigger);
	iptLHPalmButton : FB_PhysicalDigitalInput(name := 'LH Palm Button') := (in := iLHPalmButton);
	iptRHPalmButton : FB_PhysicalDigitalInput(name := 'RH Palm Button') := (in := iRHPalmButton);
	iptTopCoverClosed : FB_PhysicalDigitalInput(name := 'Top Cover Closed') := (in := iTopCoverClosed);
	iptPrinterRibbonEncoder : FB_PhysicalDigitalInput(name := 'Top Cover Closed') := (in := iPrinterRibbonEncoder);
	
	outSealWire : FB_PhysicalDigitalOutput(name := 'Seal Wire Output') := (refOutput := oSealWire);
	outLowerPrintHead : FB_PhysicalDigitalOutput(name := 'Lower Printhead') := (refOutput := oLowerPrintHead);
	outRequestPrint : FB_PhysicalDigitalOutput(name := 'Request Print') := (refOutput := oRequestPrint);
	outPrinterRibbonUnwind : FB_PhysicalDigitalOutput(name := 'Ribbon Unwind') := (refOutput := oPrinterRibbonUnwind);
	outTriggerBCV : FB_PhysicalDigitalOutput(name := 'Trigger BCV') := (refOutput := oTriggerBCV);
	outTeachPhotoeye : FB_PhysicalDigitalOutput(name := 'Teach Photoeye') := (refOutput := oTeachPhotoeye);
	outRedStackLight : FB_PhysicalDigitalOutput(name := 'Red Stack Light') := (refOutput := oRedStackLight);
	outGreenStackLight : FB_PhysicalDigitalOutput(name := 'Green Stack Light') := (refOutput := oGreenStackLight);
	outReadyForFiller : FB_PhysicalDigitalOutput(name := 'Ready for Filler') := (refOutput := oReadyForFiller);
	outPalmButton0 : FB_PhysicalDigitalOutput(name := 'Palm Button 0') := (refOutput := oPalmButton0);
	outPalmButton1 : FB_PhysicalDigitalOutput(name := 'Palm Button 1') := (refOutput := oPalmButton1);
END_VAR