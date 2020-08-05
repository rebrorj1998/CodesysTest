(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL PERSISTENT RETAIN
	// Generated instance path of persistent variable
	HMIData.bagsMade: UDINT;
	// Generated instance path of persistent variable
	HMIData.batchEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.batchSetting: UDINT := UDINT#10;
	// Generated instance path of persistent variable
	HMIData.batchCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.headCycleCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.pressureBarOpenDelay: REAL;
	// Generated instance path of persistent variable
	HMIData.pressureBarCloseDelay: REAL;
	// Generated instance path of persistent variable
	HMIData.passthroughSetting: REAL := REAL#5.5;
	// Generated instance path of persistent variable
	HMIData.sealBarDwell: REAL := REAL#0.2;
	// Generated instance path of persistent variable
	HMIData.sealBarCool: REAL := REAL#0.4;
	// Generated instance path of persistent variable
	HMIData.bagSkirtLength: REAL := 2.0;
	// Generated instance path of persistent variable
	HMIData.bagLength: REAL := REAL#17.62;
	// Generated instance path of persistent variable
	HMIData.bagWidth: REAL := 11.0;
	// Generated instance path of persistent variable
	HMIData.bagThickness: REAL := REAL#2.5;
	// Generated instance path of persistent variable
	HMIData.bagForwardSpeed: UDINT := UDINT#40;
	// Generated instance path of persistent variable
	HMIData.bagReverseSpeed: UDINT := UDINT#8;
	// Generated instance path of persistent variable
	HMIData.printSpeed: UDINT := UDINT#6;
	// Generated instance path of persistent variable
	HMIData.printLength: REAL := REAL#1.25;
	// Generated instance path of persistent variable
	HMIData.printOffset: REAL := REAL#9;
	// Generated instance path of persistent variable
	HMIData.fillerCountSetting: UDINT;
	// Generated instance path of persistent variable
	HMIData.fillerCurrentCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.fillerDropTime: REAL;
	// Generated instance path of persistent variable
	HMIData.loadPlateDelay: REAL;
	// Generated instance path of persistent variable
	HMIData.loadPlateDwell: REAL := REAL#0.1;
	// Generated instance path of persistent variable
	HMIData.IBDInUse: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.IBDInstalled: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.IBDOpenMotionProfile: sctMotionProfile := STRUCT(velo := REAL#9, accel := REAL#30, decel := REAL#50, current := REAL#100);
	// Generated instance path of persistent variable
	HMIData.IBDCloseMotionProfile: sctMotionProfile := STRUCT(velo := REAL#15, accel := REAL#10, decel := REAL#10, current := REAL#50);
	// Generated instance path of persistent variable
	HMIData.IBDZeroOffset: REAL := REAL#2;
	// Generated instance path of persistent variable
	HMIData.jawCloseDelay: REAL := REAL#0.1;
	// Generated instance path of persistent variable
	HMIData.jawClosePositionSetting: REAL := REAL#-0.45;
	// Generated instance path of persistent variable
	HMIData.jawOpenMotionProfile: sctMotionProfile := STRUCT(velo := REAL#14, accel := REAL#300, decel := REAL#300, current := REAL#100);
	// Generated instance path of persistent variable
	HMIData.jawCloseMotionProfile: sctMotionProfile := STRUCT(velo := REAL#14, accel := REAL#10, decel := REAL#10, current := REAL#100);
	// Generated instance path of persistent variable
	HMIData.jawZeroOffset: REAL := REAL#2;
	// Generated instance path of persistent variable
	HMIData.lastCycleTime: REAL;
	// Generated instance path of persistent variable
	HMIData.bagDropClearanceDwell: REAL := REAL#0.5;
	// Generated instance path of persistent variable
	HMIData.averageCycleTime: REAL;
	// Generated instance path of persistent variable
	HMIData.currentJobID: INT;
	// Generated instance path of persistent variable
	HMIData.separateBeforeSeal: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.partsCounterEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.partsCounterCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.partsCounterSetting: UDINT;
	// Generated instance path of persistent variable
	HMIData.consecutiveBagsEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.consecutiveBagsCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.consecutiveBagsSetting: UDINT;
	// Generated instance path of persistent variable
	HMIData.printerInstalled: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.printerInUse: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.printerCancelRequest: BOOL;
	// Generated instance path of persistent variable
	HMIData.barcodeVerifierInstalled: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.barcodeGoodReadCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.barcodeBadReadCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.barcodeBadReadFaultSetting: UDINT := UDINT#1;
	// Generated instance path of persistent variable
	HMIData.barcodeStartPosition: REAL := REAL#3.0;
	// Generated instance path of persistent variable
	HMIData.barcodeScanDistance: REAL := REAL#0.1;
	// Generated instance path of persistent variable
	HMIData.barcodeVerifierInUse: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.loadPlateInstalled: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.loadPlateLoweredPositionSetting: REAL := 0.0;
	// Generated instance path of persistent variable
	HMIData.loadPlateRaisedPositionSetting: REAL := 1.0;
	// Generated instance path of persistent variable
	HMIData.loadPlateInUse: BOOL := TRUE;
	// Generated instance path of persistent variable
	HMIData.loadPlateRaiseProfile: sctMotionProfile := STRUCT(velo := REAL#3, accel := REAL#100, decel := REAL#10, current := REAL#100);
	// Generated instance path of persistent variable
	HMIData.loadPlateLowerProfile: sctMotionProfile := STRUCT(velo := REAL#5, accel := REAL#100, decel := REAL#100, current := REAL#100);
	// Generated instance path of persistent variable
	HMIData.fillerEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.autoModeEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.autoModeDwell: REAL;
	// Generated instance path of persistent variable
	HMIData.dryCycleEnable: BOOL;
END_VAR