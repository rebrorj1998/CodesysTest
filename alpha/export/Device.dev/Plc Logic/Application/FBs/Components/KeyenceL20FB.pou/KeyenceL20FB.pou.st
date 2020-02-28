(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK KeyenceL20FB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
	ptrEIPInputs : POINTER TO WORD;
	ptrEIPOutputs : POINTER TO WORD;
	triggerInput : BOOL;
END_VAR
VAR_OUTPUT
	commFail : FB_Fault(name := 'Communication Fail - Bus Master to Controller');
	lastReadData : STRING[100];
	
END_VAR
VAR
	error : BOOL;
	readDataUpdateAvailable : BOOL;
	readDataUpdateComplete : BOOL;
	bufferOverflowError : BOOL;
	generalError : BOOL;
	busy : BOOL;
	readingComplete : BOOL;
	in1Status : BOOL;
	in2Status : BOOL;
	out1Status : BOOL;
	out2Status : BOOL;
	out3Status : BOOL;
	out4Status : BOOL;
	errorCode : UINT;
	readDataReadyCount : UINT;
	readDataUpdateCount : UINT;
	readDataLength : UINT;
	readData : POINTER TO STRING[100];
	
END_VAR
	
VAR_IN_OUT

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: KeyenceL20FB
//    Description: Alarms, faults, configuration of the Keyence L-N20 barcode scanner base
//    Created by: Ben Hess
//    Created Date: Feb 28th, 2020


// Exit FB if pointers are invalid
IF ptrEIPInputs = 0 OR ptrEIPOutputs = 0 THEN
	RETURN;
END_IF

// Map statuses to friendly variables
error := ptrEIPInputs[0].0;
readDataUpdateAvailable := ptrEIPInputs[0].1;
readDataUpdateComplete := ptrEIPInputs[0].2;
bufferOverflowError := ptrEIPInputs[0].6;
generalError := ptrEIPInputs[0].7;
busy := ptrEIPInputs[0].8;

readingComplete := ptrEIPInputs[1].0;

in1Status := ptrEIPInputs[2].0;
in2Status := ptrEIPInputs[2].1;
out1Status := ptrEIPInputs[2].4;
out2Status := ptrEIPInputs[2].5;
out3Status := ptrEIPInputs[2].6;
out4Status := ptrEIPInputs[2].7;

errorCode := ptrEIPInputs[16];

readDataReadyCount := ptrEIPInputs[18];
readDataUpdateCount := ptrEIPInputs[19];

readDataLength := ptrEIPInputs[21];
readData := ADR(ptrEIPInputs[22]);

// Strip terminating char (0x0D) from string to get clean read barcode
lastReadData := LEFT(readData^, readDataLength - 1);




SUPER^();