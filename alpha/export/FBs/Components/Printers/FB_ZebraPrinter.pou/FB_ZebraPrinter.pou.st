(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ZebraPrinter EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
    autoSendLabel :BOOL;    // Automatically send a label
	ribbonEncoderPulse : BOOL;	// Ribbon Encoder Input
	enableRibbonDetection : BOOL := TRUE;                
END_VAR
VAR_OUTPUT
    state : PRINTER_STATES;         // Printer State Machine
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
	printerRibbonMovingTimer1 : Standard.TON;
	printerRibbonMovingTimer2 : Standard.TON;
	printerRibbonMovingSettleTime : TIME := T#450MS;
END_VAR

VAR_IN_OUT
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
//Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = PRINTER_STATES.Fault);

printerRibbonMovingTimer1(PT := printerRibbonMovingSettleTime);
printerRibbonMovingTimer2(PT := printerRibbonMovingSettleTime);

printHeadDebounce(PT:= printHeadDebouneSetpoint, Q=> printHeadDebounced);
printStarted := printerEndOfPrint;

IF enableONS.Q OR resetONS.Q THEN
    state := PRINTER_STATES.Idle;
	_reset := FALSE;
	_amGoToIdle := FALSE;
	_amSendPrintSignal := FALSE;
	_amPrintNow := FALSE;
	printHeadDebounced := FALSE;
	oRunPrinterRibbonUnwindMotor := FALSE;
	oLowerPrintHead := FALSE;
	printerRibbonMovingTimer1.IN := FALSE;
	printerRibbonMovingTimer2.IN := FALSE;
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
    PRINTER_STATES.Idle :                            //Go to waiting for data if printer is ready
                                                    oRunPrinterRibbonUnwindMotor := FALSE;
													oPrinterStartPrint := FALSE;
													printHeadDebounce.IN := FALSE;
													printHeadDebounced := FALSE;
													printerRibbonMovingTimer1.IN := FALSE;
													printerRibbonMovingTimer2.IN := FALSE;
													IF NOT printerDataReady THEN
                                                        IF autoSendLabel THEN
                                                            tcpServer.SendLabel();
                                                        END_IF
                                                        state := PRINTER_STATES.WaitingForData;
                                                    ELSE
                                                        state := PRINTER_STATES.DataReady;
                                                    END_IF
                                                    
                                        
    
    PRINTER_STATES.WaitingForData :                    //If printerDataReady drops out the label data was received
                                                    
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
														//oPrinterStartPrint := TRUE;
                                                    END_IF                                    
            
    
    PRINTER_STATES.BeginPrintCycle :                // Start printing
                                                    
                                                    
                                                    IF _amSendPrintSignal THEN
                                                        oPrinterStartPrint := TRUE;
														
                                                        state := PRINTER_STATES.Printing;
                                                        printHeadDebounce.IN := FALSE;
                                                        _amSendPrintSignal := FALSE;
                                                    END_IF                                                    
                                        
    
    PRINTER_STATES.FeedAtPrintSpeed :                //

                                                    
                                                                                                
                                        
    PRINTER_STATES.Printing :                        //While printing, wait for End of Print signal
													printerRibbonMovingTimer1.IN := ribbonEncoderPulse;
													printerRibbonMovingTimer2.IN := NOT ribbonEncoderPulse;
                                                    IF endOfPrintONS.Q OR printerRibbonMovingTimer1.Q OR printerRibbonMovingTimer2.Q THEN
                                                        oPrinterStartPrint := FALSE;
                                                        oLowerPrintHead := FALSE;
														IF printerRibbonMovingTimer1.Q OR printerRibbonMovingTimer2.Q THEN
															ribbonFault.Trigger();
														END_IF
														printerRibbonMovingTimer1.IN := FALSE;
														printerRibbonMovingTimer2.IN := FALSE;
														 
                                                        //oRunPrinterRibbonUnwindMotor := FALSE;
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
        
    PRINTER_STATES.FeedThrough :                        
                                        
    PRINTER_STATES.Ready :                        
                                        
    PRINTER_STATES.Fault :                        
                                        
END_CASE