(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PRG_Bagger
VAR_INPUT

END_VAR
VAR_OUTPUT
    
END_VAR
VAR
	_LOTARCompleteONS : FB_ONS;
	_faulActive : BOOL;
	_faultSequenceCompleted : BOOL;
	_barcodeVerificationFailed : BOOL;
    moabHead : FB_MOABHead_Electric;
    //angledHead : FB_20degHead();
    //pneuHead : FB_PneumaticHead();
    testEIPMotor : FB_AppliedMotionStepServoEIPBase();
    faultHandler : FB_FaultHandler();
	hmiInitiate : BOOL;
	msfMotorFaults : ARRAY[0..100] OF MotorCommFault;
	numberOfMSFFaults : UINT;
	msfCommFaultONS : R_TRIG();
	msfFaultListFull : BOOL;
	festoFaults : ARRAY[0..100] OF MotorCommFault;
	numberOfFestoFaults : UINT;
	festoCommFaultONS : R_TRIG();
	festoFaultListFull : BOOL;
	currentDateAndTime : GetTime();
	resetCommFaults : BOOL;
	i : INT;
	reverseFault : FB_HMIFault := (refFault := PRG_Bagger.moabHead.bagDeliverySynchronous.reverseFault);
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

moabHead();
//pneuHead();
faultHandler();
hmiInitiate := HMIData.initiateCycle;
currentDateAndTime();
//msfCommFaultONS(CLK := MSFMotor.eState <> IoDrvEthernetIP.AdapterState.RUNNING);
HMIData.bagEdgePhotoeyeCovered := NOT iBagNotPresent;
oSoftStart := TRUE;

HMIData.airFilterClean();
HMIData.pressureBarGuideShaftGuides();
HMIData.driveRollerClean();
HMIData.printHeadClean();
//HMIData.pressureBarLeak(iExtended := iPressureBarExtended, iRetracted := iPressureBarRetracted, maximumStrokeTime := (TO_REAL(HMIData.passthroughSetting / 26.6)) + 0.3);
HMIData.loadPlateLeak(iExtended := iLoadPlateExtended, iRetracted := iLoadPlateRetracted, maximumStrokeTime := 0.4);
//HMIData.msfHorizontalMotorTemp(iDriveTemp := sealFlattenerHorizontalMotorInputs[4]);
//HMIData.bagDeliveryMotorTemp(iDriveTemp := bagDeliveryMotorInputs[4]);
//HMIData.passthroughMotorTemp(iDriveTemp := jawPasstrhoughMotorInputs[4]);




IF resetCommFaults THEN
	FOR i := 0 TO numberOfMSFFaults BY 1 DO
		msfMotorFaults[i].message := '';
		msfMotorFaults[i].timeOfFault := DT#1970-1-1-1:0:0;
	END_FOR
	numberOfMSFFaults := 0;
	msfFaultListFull := FALSE;
	resetCommFaults := FALSE;
END_IF

throughputCalculator(
	inCycle:= HMIData.inCycle, 
	runtimeTimeout:= , 
	reset:= HMIData.resetAverageCycleTime, 
	BPM=> HMIData.calculatedCyclesPerMinute, 
	BPMCycles=> , 
	BPMSeconds=> , 
	BPMIndication=> );
	
// HMIData.version := SVN_VERSION_INFO.VERSION;
faultOutTimer(PT := T#2S);
_LOTARCompleteONS(CLK := iPALOTAR);
IF _LOTARCompleteONS.OSF OR (moabHead.state = HEAD_STATES.Idle AND NOT iPALOTAR) THEN
	_faultSequenceCompleted := TRUE;
END_IF

// Test code to run bagger even with a barcode fault
IF ((HMIData.barcodeVerifierSelection = BCVSelection.TwoDimensional) AND (HMIData.printerSelection = LabelPrinterSelection.PrintAndApply300DPI)) THEN
	HMIData.faultActive := (_faulActive AND GlobalObjects.CollectionOfActiveFaults.faultActive AND NOT moabHead.barcodeVerificationFailed.active) OR (_faulActive AND moabHead.barcodeVerificationFailed.active AND _faultSequenceCompleted) OR (_faulActive AND GlobalObjects.CollectionOfActiveFaults.totalObj > 1);
ELSE
	HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;
END_IF

IF GlobalObjects.CollectionOfActiveFaults.faultActive THEN
	_faulActive := TRUE;
ELSE
	_faulActive := FALSE;
	_faultSequenceCompleted := FALSE;
END_IF

//HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;
//faultActiveONS(CLK := GlobalObjects.CollectionOfActiveFaults.faultActive);
faultActiveONS(CLK := HMIData.faultActive);
IF faultActiveONS.OSR THEN
	moabHead.hmiLight.TurnOff();
END_IF