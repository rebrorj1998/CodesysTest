(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PRG_Bagger
VAR_INPUT

END_VAR
VAR_OUTPUT
    
END_VAR
VAR
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
	reverseFault : FB_HMIFault := (refFault := PRG_Bagger.moabHead.bagDelivery.reverseFault);
	faultActiveONS : FB_ONS;
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
//msfCommFaultONS(CLK := MSFMotor.xDiagnosticAvailable);
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

//HMIData.version := SVN_VERSION_INFO.VERSION;

HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;
faultActiveONS(CLK := GlobalObjects.CollectionOfActiveFaults.faultActive);
IF faultActiveONS.OSR THEN
	moabHead.hmiLight.TurnOff();
END_IF