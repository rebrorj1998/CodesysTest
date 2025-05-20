(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)

VAR_GLOBAL RETAIN PERSISTENT
	// Generated instance path of persistent variable
	PLC_PRG_1.baggerCM.dualMotorPassthrough.factoryHomeJaw: BOOL;
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
	HMIData.printSpeed: UINT := UINT#6;
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
	HMIData.IBDInUse: BOOL;
	// Generated instance path of persistent variable
	HMIData.IBDInstalled: BOOL := FALSE;
	// Generated instance path of persistent variable
	HMIData.jawCloseDelay: REAL := REAL#0.1;
	// Generated instance path of persistent variable
	HMIData.jawClosePositionSetting: REAL;
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
	HMIData.printerInstalled: BOOL := FALSE;
	// Generated instance path of persistent variable
	HMIData.printerInUse: BOOL := FALSE;
	// Generated instance path of persistent variable
	HMIData.printerCancelRequest: BOOL;
	// Generated instance path of persistent variable
	HMIData.barcodeVerifierInstalled: BOOL := FALSE;
	// Generated instance path of persistent variable
	HMIData.barcodeGoodReadCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.barcodeBadReadCount: UDINT;
	// Generated instance path of persistent variable
	HMIData.barcodeBadReadFaultSetting: UDINT := UDINT#1;
	// Generated instance path of persistent variable
	HMIData.barcodeStartPosition: REAL := REAL#4.5;
	// Generated instance path of persistent variable
	HMIData.barcodeScanDistance: REAL := REAL#0.1;
	// Generated instance path of persistent variable
	HMIData.barcodeVerifierInUse: BOOL;
	// Generated instance path of persistent variable
	HMIData.loadPlateInstalled: BOOL := FALSE;
	// Generated instance path of persistent variable
	HMIData.loadPlateLoweredPositionSetting: REAL := 0.0;
	// Generated instance path of persistent variable
	HMIData.loadPlateRaisedPositionSetting: REAL := 1.0;
	// Generated instance path of persistent variable
	HMIData.loadPlateInUse: BOOL;
	// Generated instance path of persistent variable
	HMIData.fillerEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.autoModeEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.autoModeDwell: REAL;
	// Generated instance path of persistent variable
	HMIData.dryCycleEnable: BOOL;
	// Generated instance path of persistent variable
	HMIData.standbyTimeSetting: REAL := REAL#5;
	// Generated instance path of persistent variable
	HMIData.jawClampTime: REAL := REAL#1;
	// Generated instance path of persistent variable
	HMIData.jawClampReverseTime: REAL := REAL#1;
	// Generated instance path of persistent variable
	HMIData.jawClampInterval: REAL := REAL#2;
	// Generated instance path of persistent variable
	HMIData.jawEnableClamping: BOOL;
	// Generated instance path of persistent variable
	HMIData.jawCycleTestCycles: DINT;
	// Generated instance path of persistent variable
	HMIData.jawClampTestCycles: DINT;
	// Generated instance path of persistent variable
	HMIData.filmFeedTestCycles: DINT;
	// Generated instance path of persistent variable
	HMIData.jawEnableMotion: BOOL;
	// Generated instance path of persistent variable
	HMIData.filmEnableMotion: BOOL;
	// Generated instance path of persistent variable
	HMIData.printer300DPI: BOOL;
	// Generated instance path of persistent variable
	HMIData.HMIMetric: BOOL;
	AxisData.jawJogMotionProfile: sctMotionProfile := STRUCT(acceleration := 200.0, deceleration := 200.0, velocity := 2.0, minPosition := REAL#0.0, maxPosition := 5.5, current := REAL#30);
	// Generated instance path of persistent variable
	AxisData.jawConfig: sctAxisConfig := STRUCT(stepsPerInch := 2410.0, rotationsPerInch := REAL#0.241, zeroOffset := 0.0, defaultCurrent := REAL#100);
	// Generated instance path of persistent variable
	AxisData.jawOpenMotionProfile: sctMotionProfile := STRUCT(acceleration := 100.0, deceleration := 100.0, velocity := REAL#30, current := REAL#100, position := REAL#5.5);
	// Generated instance path of persistent variable
	AxisData.jawCloseMotionProfile: sctMotionProfile := STRUCT(acceleration := 100.0, deceleration := 100.0, velocity := REAL#30, current := REAL#100, position := REAL#-0.5);
	// Generated instance path of persistent variable
	AxisData.jawPushMotionProfile: sctMotionProfile := STRUCT(acceleration := 100.0, deceleration := 100.0, velocity := 4.0, current := REAL#100, position := -1.0);
	// Generated instance path of persistent variable
	AxisData.loadPlateConfig: sctAxisConfig := STRUCT(stepsPerInch := 9310.0, rotationsPerInch := REAL#0.931, zeroOffset := REAL#0);
	// Generated instance path of persistent variable
	AxisData.loadPlateRaiseMotionProfile: sctMotionProfile := STRUCT(acceleration := REAL#300000, deceleration := REAL#300000, velocity := REAL#10, current := REAL#100);
	// Generated instance path of persistent variable
	AxisData.loadPlateLowerMotionProfile: sctMotionProfile := STRUCT(acceleration := REAL#300000, deceleration := REAL#300000, velocity := REAL#10000, current := REAL#100);
	// Generated instance path of persistent variable
	AxisData.IBDConfig: sctAxisConfig := STRUCT(stepsPerInch := 12500.0, rotationsPerInch := REAL#1.25, zeroOffset := REAL#2);
	// Generated instance path of persistent variable
	AxisData.IBDJogMotionProfile: sctMotionProfile := STRUCT(acceleration := 0.0, deceleration := 0.0, velocity := 0.0, minPosition := 0.0, maxPosition := 0.0);
	// Generated instance path of persistent variable
	AxisData.IBDOpenMotionProfile: sctMotionProfile := STRUCT(acceleration := REAL#300000, deceleration := REAL#300000, velocity := REAL#10000, current := REAL#100);
	// Generated instance path of persistent variable
	AxisData.IBDCloseMotionProfile: sctMotionProfile := STRUCT(acceleration := REAL#300000, deceleration := REAL#300000, velocity := REAL#10, current := REAL#50);
	// Generated instance path of persistent variable
	AxisData.FilmFeedConfig: sctAxisConfig := STRUCT(stepsPerInch := 4900.0, rotationsPerInch := REAL#0.49, zeroOffset := REAL#2, defaultCurrent := REAL#100);
	// Generated instance path of persistent variable
	AxisData.FilmFeedJogMotionProfile: sctMotionProfile := STRUCT(acceleration := 10.0, deceleration := 200.0, velocity := 100.0, minPosition := -20.0, maxPosition := 20.0, position := 20.0, current := 100.0);
	// Generated instance path of persistent variable
	AxisData.FilmFeedForwardMotionProfile: sctMotionProfile := STRUCT(acceleration := 75.0, deceleration := 100.0, velocity := 60.0, position := REAL#17.5, current := REAL#100);
	// Generated instance path of persistent variable
	AxisData.FilmFeedReverseMotionProfile: sctMotionProfile := STRUCT(acceleration := 50.0, deceleration := 50.0, velocity := 12.0, position := -1.0, current := REAL#100);
	// Generated instance path of persistent variable
	AxisData.FilmFeedPrintMotionProfile: sctMotionProfile := STRUCT(acceleration := 100.0, deceleration := 100.0, velocity := 12.0, position := -1.0, current := REAL#100);
	// Generated instance path of persistent variable
	AxisData.FilmFeedPrintOffsetMotionProfile: sctMotionProfile := STRUCT(acceleration := 75.0, deceleration := 100.0, velocity := 12.0, position := -1.0, current := REAL#100);
	// Generated instance path of persistent variable
	HMIData.partsCounterDone: BOOL;
	// Generated instance path of persistent variable
	HMIData.lightCurtainInstalled: BOOL;
END_VAR