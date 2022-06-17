(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ZebraPrinter EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
    autoSendLabel :BOOL;    // Automatically send a label
	ribbonEncoderPulse : BOOL;	// Ribbon Encoder Input
	enableRibbonDetection : BOOL := TRUE;                
END_VAR
VAR_OUTPUT
    state : PRINTER_STATES; // Printer State Machine
	oLowerPrintHead : BOOL;
	printHeadDebounced : BOOL;
	ribbonFault : FB_Fault(name := 'Printer Ribbon Fault');
END_VAR
VAR
    _amPrintNow : BOOL;                // Auto mode - print now
    _amSendPrintSignal : BOOL;        // Auto mode - send print signal
    _amGoToIdle : BOOL;                // Auto mode - Acked, go back to idle mode
    printHeadDebounce : TON;
	printStarted : BOOL;
    printHeadDebouneSetpoint : TIME := T#50MS;
    tcpServer : FB_TCPClient();
	endOfPrintONS : Standard.F_TRIG();
	printerNotPrintingFault : FB_Fault(name := 'Printer didnt respond to print request');
	printerNotPrintingTimer : Standard.TON := (PT := T#250MS);
	_printerRibbonTimeoutTimer : Standard.TON := (PT := T#500MS);
	_printRibbonStateChanges : SINT;
	_previousRibbonState : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: Printer
//    Description: This program manages the aspects of a (Zebra) printer
//    Created by: Ben Hess
//    Created Date: April 2nd, 2018

SUPER^();

// Enable TCP Server for label sending
tcpServer();
endOfPrintONS(CLK := printerEndOfPrint);

// Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = PRINTER_STATES.Fault);

// // Turned off until fault is added to the HMI
// printerNotPrintingTimer(IN := oPrinterStartPrint AND NOT printerEndOfPrint);
// IF printerNotPrintingTimer.Q THEN
// 	printerNotPrintingFault.Trigger();
// END_IF

_printerRibbonTimeoutTimer();

printHeadDebounce(PT:= printHeadDebouneSetpoint, Q=> printHeadDebounced);

IF enableONS.Q OR resetONS.Q THEN
    state := PRINTER_STATES.Idle;
	_reset := FALSE;
	_amGoToIdle := FALSE;
	_amSendPrintSignal := FALSE;
	_amPrintNow := FALSE;
	printHeadDebounced := FALSE;
	oRunPrinterRibbonUnwindMotor := FALSE;
	oLowerPrintHead := FALSE;
END_IF

IF NOT enable THEN
    state := PRINTER_STATES.Fault;
	oRunPrinterRibbonUnwindMotor := FALSE;
	oLowerPrintHead := FALSE;
END_IF

IF HMIData.printHeadServiceRaise THEN
	oLowerPrintHead := FALSE;
	HMIData.printHeadServiceRaise := FALSE;
ELSIF HMIData.printHeadServiceLower THEN
	oLowerPrintHead := TRUE;
	HMIData.printHeadServiceLower := FALSE;
END_IF


//State machine for the printer
CASE state OF
    PRINTER_STATES.Idle :                           // Go to waiting for data if printer is ready
 													_printRibbonStateChanges := 0;
													_printerRibbonTimeoutTimer.IN := FALSE;
                                                    oRunPrinterRibbonUnwindMotor := FALSE;
													oPrinterStartPrint := FALSE;
													printHeadDebounce.IN := FALSE;
													printHeadDebounced := FALSE;
													IF NOT printerDataReady THEN
                                                        IF autoSendLabel THEN
                                                            tcpServer.SendLabel();
                                                        END_IF
                                                        state := PRINTER_STATES.WaitingForData;
                                                    ELSE
                                                        state := PRINTER_STATES.DataReady;
                                                    END_IF
                                                    
    PRINTER_STATES.WaitingForData :                 // If printerDataReady drops out the label data was received
                                                    IF printerDataReady THEN
                                                        state := PRINTER_STATES.DataReady;    
                                                    END_IF
                                                
    PRINTER_STATES.DataReady :                        // Wait for command to begin printing
                                                    IF NOT printerDataReady THEN
														state := PRINTER_STATES.Idle;
													END_IF
													IF _mode = DEVICE_MODES.Auto AND _amPrintNow THEN
                                                        state := PRINTER_STATES.BeginPrintCycle;
                                                        _amPrintNow := FALSE;
														printHeadDebounce.IN := TRUE;
                                                        oLowerPrintHead := TRUE;
                                                        oRunPrinterRibbonUnwindMotor := TRUE;
                                                    END_IF                                    
            
    PRINTER_STATES.BeginPrintCycle :                // Start printing
                                                    IF _amSendPrintSignal THEN
                                                        oPrinterStartPrint := TRUE;
														_amSendPrintSignal := FALSE;
                                                        printHeadDebounce.IN := FALSE;
														state := PRINTER_STATES.Printing;
														_previousRibbonState := ribbonEncoderPulse;
                                                    END_IF                                                    
                                        
    PRINTER_STATES.Printing :                       
													//	
													IF _previousRibbonState <> ribbonEncoderPulse THEN
														_printRibbonStateChanges := _printRibbonStateChanges + 1;
														_previousRibbonState := ribbonEncoderPulse;
													END_IF
													
													_printerRibbonTimeoutTimer.IN := _printRibbonStateChanges = 0;
													IF _printerRibbonTimeoutTimer.Q THEN
														ribbonFault.Trigger();
														state := PRINTER_STATES.Idle; 
													END_IF
													
													// While printing, wait for End of Print signal
                                                    IF endOfPrintONS.Q THEN
                                                        oPrinterStartPrint := FALSE;
                                                        oLowerPrintHead := FALSE;
                                                        state := PRINTER_STATES.DonePrinting;    
                                                    END_IF
                                        
    PRINTER_STATES.DonePrinting :                    //Done printing, feed a little more through
                                                    IF _mode = DEVICE_MODES.Auto AND _amGoToIdle THEN
                                                        oRunPrinterRibbonUnwindMotor := FALSE;
                                                        state := PRINTER_STATES.Idle;
                                                        _amGoToIdle := FALSE;
														HMIData.printerCycles.Increment();
														HMIData.printHeadClean.Increment();
                                                        Globals.printerCycleCounts := Globals.printerCycleCounts + 1;
                                                    END_IF                       
                                        
END_CASE