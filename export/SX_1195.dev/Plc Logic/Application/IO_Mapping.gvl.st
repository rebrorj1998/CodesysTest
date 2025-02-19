(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)

VAR_GLOBAL
	mainIOamax4830Input: ARRAY[0..15] OF universalIOObject;
	mainIOamax4830Output: ARRAY[0..15] OF universalIOObject;
	oSealWire: REFERENCE TO BOOL;
	oLowerPrinthead: Reference to BOOL;
	oRequestPrint: Reference to BOOL;
	oPrinterRibbonUnwind: Reference to BOOL;
	oTriggerBCV: Reference to BOOL;
	oFansEnable: Reference to BOOL;
	oPalmButton0: Reference to BOOL;
	oPalmButton1: Reference to BOOL;
	oPbarClampMotorStart: Reference to BOOL;
	oPbarClampMotorReverse: Reference to BOOL;
	oPbarClampMotorAlarmReset: Reference to BOOL;
	iPrinterServiceRequired: Reference to BOOL;
	iPrinterDataReady: Reference to BOOL;
	iPrinterBusy: Reference to BOOL;
	iBagEdgePhotoeye: Reference to BOOL;
	iCycleStart: Reference to BOOL;
	iPbarClampMotorAlarm: Reference to BOOL;
	iClampHomeSensor: Reference to BOOL;
	iJawNotObstructed: Reference to BOOL;
	iBarcodeOK: Reference to BOOL;
	iBarcodeNG: Reference to BOOL;
	iLightCurtainClear: REFERENCE TO BOOL;
	iLightCurtainStart: REFERENCE TO BOOL;
	iSafePowerOK: Reference to BOOL;
	iPrinterRibbonEncoder: REFERENCE TO BOOL;
	iEstopNormal: REFERENCE TO BOOL;
END_VAR