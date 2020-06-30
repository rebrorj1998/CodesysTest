(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionAlarms
VAR_INPUT
    alarmCode : WORD;
END_VAR
VAR_OUTPUT
    positionLimit : BOOL;        // FAULT - Motor exceeded position limit - following error
    CCWLimit : BOOL;      // WARNING - Motor is at CCW Limit
    CWLimit : BOOL;      // WARNING - Motor is at CW Limit
    overTemp : BOOL;      // FAULT - Motor Over Temperature Limit
    internalVoltage : BOOL;      // FAULT - Internal Voltage Fault
    overVoltage    : BOOL;      // FAULT - Overvoltage Fault
    underVoltage : BOOL;      // WARNING - Undervoltage Warning
    overCurrent : BOOL;      // FAULT - Motor Overcurrent
    openMotorWinding : BOOL;      // FAULT - Motor Detected Open Winding
    badEncoder : BOOL;      // FAULT - Motor Encoder Failure
    commError : BOOL;      // WARNING - Communications Error
    badFlash : BOOL;      // WARNING - Bad Flash
    noMove : BOOL;      // WARNING - No Move
    currentFoldback    : BOOL;      // WARNING - Current Foldback
    blankQSegment : BOOL;      // WARNING - Blank Q Segment
    NVMemoryDoubleError : BOOL;      // WARNING - NV Memory Double Error
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Fucntion Block: FB_StepServoAlarms
//    Description: This unpacks the step servo alarm bits from the alarm word received over EIP
//    Created by: Ben Hess
//    Created Date: September 5th, 2018

positionLimit := alarmCode.0;
CCWLimit := alarmCode.1;
CWLimit := alarmCode.2;
overTemp := alarmCode.3;
internalVoltage := alarmCode.4;
overVoltage := alarmCode.5;
underVoltage := alarmCode.6;
overCurrent    := alarmCode.7;
openMotorWinding := alarmCode.8;
badEncoder := alarmCode.9;
commError := alarmCode.10;
badFlash := alarmCode.11;
noMove := alarmCode.12;
currentFoldback := alarmCode.13;
blankQSegment := alarmCode.14;
NVMemoryDoubleError := alarmCode.15;
