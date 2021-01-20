(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK KeyenceNL20FB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
	ptrEIPInputs : POINTER TO WORD;
	ptrEIPOutputs : POINTER TO WORD;
	triggerInput : BOOL;
END_VAR
VAR_OUTPUT
	lastReadData : STRING[100];
	xBusy : BOOL;
	xDone : BOOL;
	goodRead : BOOL;
	badRead : BOOL;
END_VAR
VAR
	error : BOOL;
	readDataUpdateAvailable : BOOL;
	readDataUpdateComplete : BOOL;
	bufferOverflowError : BOOL;
	generalError : BOOL;
	bcvBusy : BOOL;
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
	
	readDataUpdatePermitted : BOOL;
	errorAndBufferClear : BOOL;
	readingStartRequest : BOOL;
	readingCompleteAck : BOOL;
	bankNumber : UINT;
	
	state : eKeyenceLN20FB_States;
	triggerONS : FB_ONS;
	readingCompleteTrigger : MonostableMultivibratorFB();
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
triggerONS(CLK := triggerInput);

readingCompleteTrigger.DwellSetting := 500;
readingCompleteTrigger(Q => readingCompleteAck);
// Map statuses to friendly variables
error := ptrEIPInputs[0].0;
readDataUpdateAvailable := ptrEIPInputs[0].1;
readDataUpdateComplete := ptrEIPInputs[0].2;
bufferOverflowError := ptrEIPInputs[0].6;
generalError := ptrEIPInputs[0].7;
bcvBusy := ptrEIPInputs[0].8;

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


IF resetONS.Q THEN
	state := eKeyenceLN20FB_States.Reset;
END_IF



CASE state OF
	eKeyenceLN20FB_States.Idle: 			//
											IF readingComplete THEN
													readingCompleteTrigger.Trigger();
												END_IF
											IF triggerONS.OSR THEN
												readingStartRequest := TRUE;
												xBusy := TRUE;
												xDone := FALSE;
												badRead := FALSE;
												goodRead := FALSE;
												lastReadData := '---Read in Progress---';
												state := eKeyenceLN20FB_States.WaitForStatus;
											END_IF

	eKeyenceLN20FB_States.WaitForStatus:	//
											IF readingComplete OR NOT triggerInput THEN
												state := eKeyenceLN20FB_States.SetStatus;
												readingStartRequest := FALSE;
												IF readingComplete THEN
													readingCompleteTrigger.Trigger();
												END_IF
												
											END_IF
	
	eKeyenceLN20FB_States.SetStatus:		// Set the current read status and string
											// If trigger input goes away or barcode error seen set bad read
											IF NOT triggerInput OR out2Status THEN
												badRead := TRUE;
												goodRead := FALSE;
												state := eKeyenceLN20FB_States.WaitForReadClear;
												IF out2Status THEN
													lastReadData := '---BAD READ---';
												ELSE
													lastReadData := '---NO READ---';
												END_IF
											ELSIF out1Status THEN
												goodRead := TRUE;
												badRead := FALSE;
												// Strip terminating char (0x0D) from string to get clean read barcode
												lastReadData := LEFT(readData^, readDataLength - 1);
												state := eKeyenceLN20FB_States.WaitForReadClear;
											END_IF
											
	eKeyenceLN20FB_States.WaitForReadClear:	//
											IF readingComplete THEN
												readingCompleteTrigger.Trigger();
											END_IF
											IF NOT readingComplete THEN
												xBusy := FALSE;
												xDone := TRUE;
												state := eKeyenceLN20FB_States.Idle;
											END_IF 									

	eKeyenceLN20FB_States.Reset: 			//
											IF readingComplete THEN
												readingCompleteTrigger.Trigger();
											END_IF
											
												readingStartRequest := FALSE;
												xBusy := FALSE;
												xDone := FALSE;
												badRead := FALSE;
												goodRead := FALSE;
												state := eKeyenceLN20FB_States.Idle;
											
END_CASE	

// Outputs to barcode verifier
ptrEIPOutputs[0].1 :=  readDataUpdatePermitted;
ptrEIPOutputs[0].7 :=  errorAndBufferClear;
ptrEIPOutputs[0].8 := readingStartRequest;
ptrEIPOutputs[1].0 := readingCompleteAck;
ptrEIPOutputs[2] := bankNumber;

// Call to super FB.
SUPER^();