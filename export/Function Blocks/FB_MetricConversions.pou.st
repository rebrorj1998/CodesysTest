(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MetricConversions
VAR_INPUT
    bagLengthIn : REAL;
    bagWidthIn : REAL;
    bagSkirtLengthIn : REAL;
    sealBarTempIn : REAL;
    printSpeedIn : UDINT;
    printOffsetIn : REAL;
    printLengthIn : REAL;
    passthroughSettingIn : REAL;
    jawClosePositionSettingIn : REAL;
    barcodeStartPositionIn : REAL;
    barcodeScanningDistanceIn : REAL;
	feedSpeedIn : REAL;
    reverseSpeedIn : REAL;
END_VAR
VAR_OUTPUT
    bagLengthOut : REAL;
    bagWidthOut : REAL;
    bagSkirtLengthOut : REAL;
    sealBarTempOut : REAL;
    printSpeedOut : UDINT;
    printOffsetOut : REAL;
    printLengthOut : REAL;
    passthroughSettingOut : REAL;
    jawClosePositionSettingOut : REAL;
    barcodeStartPositionOut : REAL;
    barcodeScanningDistanceOut : REAL;
   	feedSpeedOut : REAL;
    reverseSpeedOut : REAL;
END_VAR
VAR 
    _ConvertMetricToInch: F_TRIG;
    _ConvertInchToMetric: R_TRIG;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_ModbusDWORD
//    Description: Automatically converts inches to mm every time an inch value changes.
//    
//    Created by: Steve Olson
//    Created Date: Friday, January 3, 2025

_ConvertInchToMetric(CLK := HMIData.HMIMetric);
_ConvertMetricToInch(CLK := HMIData.HMIMetric);

IF HMIData.HMIMetric THEN
    bagLengthOut := bagLengthIn / 25.4;
    bagWidthOut := bagWidthIn / 25.4;
    bagSkirtLengthOut := bagSkirtLengthIn / 25.4;
    printSpeedOut := LREAL_TO_UDINT(printSpeedIn / 25.4);
    printOffsetOut := printOffsetIn / 25.4;
    printLengthOut := printLengthIn / 25.4;
    passthroughSettingOut := passthroughSettingIn / 25.4;
    jawClosePositionSettingOut := jawClosePositionSettingIn / 25.4;
    barcodeStartPositionOut := barcodeStartPositionIn / 25.4;
    sealBarTempOut := (sealBarTempIn - 32) * 5 / 9; // Fahrenheit to Celsius
    feedSpeedOut := feedSpeedIn / 25.4;
    reverseSpeedOut := reverseSpeedIn / 25.4;
ELSE
    bagLengthOut := bagLengthIn;
    bagWidthOut := bagWidthIn;
    bagSkirtLengthOut := bagSkirtLengthIn;
    printSpeedOut := printSpeedIn;
    printOffsetOut := printOffsetIn;
    printLengthOut := printLengthIn;
    passthroughSettingOut := passthroughSettingIn;
    jawClosePositionSettingOut := jawClosePositionSettingIn;
    barcodeStartPositionOut := barcodeStartPositionIn;
    sealBarTempOut := sealBarTempIn;
    feedSpeedOut := feedSpeedIn;
    reverseSpeedOut := reverseSpeedIn;
END_IF

HMIData.HMIMetric; // testing visibility

IF _ConvertInchToMetric.Q THEN
    HMIData.bagLength := bagLengthIn * 25.4;
    HMIData.bagSkirtLength := bagSkirtLengthIn * 25.4;
    HMIData.printOffset := printOffsetIn * 25.4;
    HMIData.printLength := printLengthIn * 25.4;
    HMIData.passthroughSetting := passthroughSettingIn * 25.4;
    HMIData.jawClosePositionSetting := jawClosePositionSettingIn * 25.4;
    HMIData.barcodeStartPosition := barcodeStartPositionIn * 25.4;
	HMIData.printSpeed := REAL_TO_UINT(printSpeedIn * 25.4);
    sealBarTempOut := (sealBarTempIn - 32) * 5 / 9; // Fahrenheit to Celsius
    feedSpeedOut := feedSpeedIn * 25.4;
    reverseSpeedOut := reverseSpeedIn * 25.4;
END_IF

IF _ConvertMetricToInch.Q THEN
    HMIData.bagLength := bagLengthIn / 25.4;
    HMIData.bagSkirtLength := bagSkirtLengthIn / 25.4;
    HMIData.printOffset := printOffsetIn / 25.4;
    HMIData.printLength := printLengthIn / 25.4;
    HMIData.passthroughSetting := passthroughSettingIn / 25.4;
    HMIData.jawClosePositionSetting := jawClosePositionSettingIn / 25.4;
    HMIData.barcodeStartPosition := barcodeStartPositionIn / 25.4;
	HMIData.printSpeed := REAL_TO_UINT(printSpeedIn / 25.4);
    sealBarTempOut := (sealBarTempIn * 9 / 5) + 32; // Celsius to Fahrenheit
    feedSpeedOut := feedSpeedIn / 25.4;
    reverseSpeedOut := reverseSpeedIn / 25.4;
END_IF
