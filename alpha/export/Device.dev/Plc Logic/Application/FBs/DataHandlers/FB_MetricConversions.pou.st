(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MetricConversions
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_ModbusDWORD
//    Description: Automatically converts inches to mm every time an inch value changes.
//    
//    Created by: Steve Olson
//    Created Date: Friday, January	3, 2025

IF HMIData.HMIMetric THEN
	
	HMIData.passthroughPosition := HMIData.passthroughPositionMetric/25.4;
	(*HMIData.sealFlattenersPosition : REAL;
	HMIData.bagLength : REAL := 23.5;
	HMIData.bagWidth : REAL := 17.5;
	HMIData.bagThickness : REAL := 2.5;
	HMIData.printLength : REAL := 8.0;
	HMIData.printOffset : REAL := 2.0;
	HMIData.barcodeStartPosition : REAL;*)

ELSE	

	HMIData.passthroughPositionMetric : ;
	(*HMIData.sealFlattenersPositionMetric : REAL;
	HMIData.bagLengthMetric : REAL := 23.5;
	HMIData.bagWidthMetric : REAL := 17.5;
	HMIData.bagThicknessMetric : REAL := 2.5;
	HMIData.printLengthMetric : REAL := 8.0;
	HMIData.printOffsetMetric : REAL := 2.0;
	HMIData.barcodeStartPositionMetric : REAL;*)

END_IF