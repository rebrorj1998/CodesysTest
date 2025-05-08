(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PRG_Bagger
VAR_INPUT

END_VAR
VAR_OUTPUT
    
END_VAR
VAR
	_LOTARCompleteONS : FB_ONS;
	_faultActive : BOOL;
	_faultSequenceCompleted : BOOL;
	_barcodeVerificationFailed : BOOL;
    moabHead : FB_MOABHead_Electric;
	faultActiveONS : FB_ONS;
	throughputCalculator : FB_Throughput();
	faultOutTimer : TON();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Program: PRG_Bagger 
//    Description: This program glues together the whole machine and all of its components.
//    
//    Created by: Ben Hess
//    Created Date: Tuesday, April 17, 2018

// Main business logic for the machine is in the FB_MOABHead_Electric function block
moabHead();

// Indication for bag edge photoeye on HMI
HMIData.bagEdgePhotoeyeCovered := NOT iBagNotPresent;

// If running, enable air. Will physically be cut on estop.
oSoftStart := TRUE;

// Run predictive/preventative maintenance
HMIData.airFilterClean();
HMIData.pressureBarGuideShaftGuides();
HMIData.driveRollerClean();
HMIData.printHeadClean();
//HMIData.pressureBarLeak(iExtended := iPressureBarExtended, iRetracted := iPressureBarRetracted, maximumStrokeTime := (TO_REAL(HMIData.passthroughSetting / 26.6)) + 0.3);
HMIData.loadPlateLeak(iExtended := iLoadPlateExtended, iRetracted := iLoadPlateRetracted, maximumStrokeTime := 0.4);
//HMIData.msfHorizontalMotorTemp(iDriveTemp := sealFlattenerHorizontalMotorInputs[4]);
//HMIData.bagDeliveryMotorTemp(iDriveTemp := bagDeliveryMotorInputs[4]);
//HMIData.passthroughMotorTemp(iDriveTemp := jawPasstrhoughMotorInputs[4]);

// Bags per minute calculation for display
throughputCalculator(
	inCycle:= HMIData.inCycle, 
	runtimeTimeout:= , 
	reset:= HMIData.resetAverageCycleTime, 
	BPM=> HMIData.calculatedCyclesPerMinute, 
	BPMCycles=> , 
	BPMSeconds=> , 
	BPMIndication=> );
	
faultActiveONS(CLK := HMIData.faultActive);
IF faultActiveONS.OSR THEN
	moabHead.hmiLight.TurnOff();
END_IF