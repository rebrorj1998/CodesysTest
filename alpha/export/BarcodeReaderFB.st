

FUNCTION_BLOCK BarcodeReaderFB EXTENDS BaseComponentFB
VAR_INPUT
	delayToCheckReadStatus : TIME;
	readGoodInput : BOOL;
END_VAR	
VAR_OUTPUT
	triggerScannerOutput : BOOL;
END_VAR
VAR
	_goodRead : BOOL;
	_badread : BOOL;
	_trigger : BOOL;
	state : BCR_STATES;
END_VAR

//    Function Block: BarcodeReaderFB
//    Description: Trigger the barcode verifier and receive a "Barcode OK" signal, or nothing which indicates no read.
//    Created by: Ben Hess
//    Created Date: January 29th, 2020

IF _reset THEN
	//
	state := BCR_STATES.Idle;
END_IF

CASE state OF
	
	BCR_STATES.Idle:				// Wait for trigger
									IF _trigger THEN
										state := BCR_STATES.TriggerReader;
									END_IF
	
	BCR_STATES.TriggerReader:	
	
	BCR_STATES.WaitingForResult:
	
	BCR_STATES.Resetting:
	
END_CASE

SUPER^();

PROPERTY GoodRead : BOOL

METHOD Trigger : BOOL
VAR_INPUT
END_VAR


PROPERTY BadRead : BOOL