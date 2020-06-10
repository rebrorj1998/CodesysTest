(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ZebraPrinter EXTENDS FB_BasicPrinter
VAR_INPUT
	printHeadDebounceSetting : TIME := T#50MS;
	printHeadDownInput : BOOL;
	dataReadyInput : BOOL;
	serviceRequiredInput : BOOL;
	ribbonLowInput : BOOL;
	endOfPrintInput : BOOL;
	ribbonEncoderPulseInput : BOOL;
	serviceRaisePrintHead : BOOL;
	serviceLowerPrintHead : BOOL;
END_VAR
VAR_OUTPUT
	serviceRequired : FB_Fault(name := Standard.CONCAT(_prefix,'Service Required'));
	ribbonFault : FB_Fault(name := 'Printer Ribbon Fault');
	printHeadFailToLower : FB_Fault(name := 'Printhead Failed to Lower');
	printHeadFailToRaise : FB_Fault(name := 'Printhead Failed to Raise');
	printHeadDebounced : BOOL;
	startPrintOutput : BOOL;
	ribbonUnwindRunOutput : BOOL;
	lowerPrintHeadOutput : BOOL;
	waitingForPrinter : BOOL;
END_VAR
VAR
	printHeadDebounce : TON;
	printHeadLowerFaultTimer : Standard.TON := (PT := T#1S);
	printHeadRaiseFaultTimer : Standard.TON := (PT := T#1S);
	endOfPrintONS : Standard.F_TRIG();
	printerRibbonMovingTimer1 : Standard.TON;
	printerRibbonMovingTimer2 : Standard.TON;
	printerRibbonMovingSettleTime : TIME := T#450MS;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_ZebraPrinter
//    Description: This program manages the aspects of a (Zebra) printer
//    Created by: Ben Hess
//    Created Date: April 2nd, 2018
SUPER^();

_hasLabel := dataReadyInput OR simulateIO;

endOfPrintONS(CLK := endOfPrintInput);
//Report as ready if mode is auto and we're not faulted
_ready := NOT (state = eZebraPrinterStates.Fault);

printerRibbonMovingTimer1(PT := printerRibbonMovingSettleTime);
printerRibbonMovingTimer2(PT := printerRibbonMovingSettleTime);

printHeadDebounce(PT:= printHeadDebounceSetting, Q=> printHeadDebounced);

waitingForPrinter := state = eZebraPrinterStates.WaitingForData;
printHeadLowerFaultTimer(IN := lowerPrintHeadOutput AND NOT printHeadDownInput);
printHeadRaiseFaultTimer(IN := NOT lowerPrintHeadOutput AND printHeadDownInput);

IF printHeadLowerFaultTimer.Q AND THIS^.OptionEnabled THEN
	printHeadFailToLower.Trigger();
END_IF

IF printHeadRaiseFaultTimer.Q AND THIS^.OptionEnabled THEN
	printHeadFailToRaise.Trigger();
END_IF

IF serviceRequiredInput AND THIS^.OptionEnabled THEN
	serviceRequired.Trigger();
END_IF
resetONS(CLK := _reset);
IF enableONS.Q OR resetONS.Q THEN
    state := eZebraPrinterStates.Idle;
	_reset := FALSE;
	printHeadDebounced := FALSE;
	ribbonUnwindRunOutput := FALSE;
	lowerPrintHeadOutput := FALSE;
	printerRibbonMovingTimer1.IN := FALSE;
	printerRibbonMovingTimer2.IN := FALSE;
END_IF

IF NOT THIS^.OptionEnabled THEN
    state := eZebraPrinterStates.Fault;
	ribbonUnwindRunOutput := FALSE;
	lowerPrintHeadOutput := FALSE;
END_IF




//State machine for the printer
CASE state OF
    eZebraPrinterStates.Idle :                            //Go to waiting for data if printer is ready
                                                    ribbonUnwindRunOutput := FALSE;
													startPrintOutput := FALSE;
													printHeadDebounce.IN := FALSE;
													printHeadDebounced := FALSE;
													printerRibbonMovingTimer1.IN := FALSE;
													printerRibbonMovingTimer2.IN := FALSE;
													_printing := FALSE;
													IF _beginPrinting AND THIS^.OptionEnabled THEN
														IF NOT dataReadyInput THEN
															state := eZebraPrinterStates.WaitingForData;
														ELSE
															state := eZebraPrinterStates.DataReady;
														END_IF
													END_IF
													
                                                    IF serviceRaisePrintHead THEN
														lowerPrintHeadOutput := FALSE;
													ELSIF serviceLowerPrintHead THEN
														lowerPrintHeadOutput := TRUE;
													END_IF
                                        
    
    eZebraPrinterStates.WaitingForData :                    //If printerDataReady drops out the label data was received
                                                    
                                                    IF dataReadyInput THEN
                                                        state := eZebraPrinterStates.DataReady;    
                                                    END_IF
                                                
    eZebraPrinterStates.DataReady :                        // Wait for command to begin printing
                                                    IF NOT dataReadyInput THEN
														state := eZebraPrinterStates.Idle;
													END_IF
													IF _beginPrinting THEN
                                                        state := eZebraPrinterStates.BeginPrintCycle;
                                                        _beginPrinting := FALSE;
														_printing := TRUE;
														printHeadDebounce.IN := TRUE;
                                                        lowerPrintHeadOutput := TRUE;
                                                        ribbonUnwindRunOutput := TRUE;
														//oPrinterStartPrint := TRUE;
                                                    END_IF                                    
            
    
    eZebraPrinterStates.BeginPrintCycle :                // Start printing
                                                    
                                                    
                                                    IF printHeadDebounced THEN
                                                        startPrintOutput := TRUE;
                                                        state := eZebraPrinterStates.Printing;
                                                        printHeadDebounce.IN := FALSE;
                                                    END_IF                                                    
                                              
                                                                                                
                                        
    eZebraPrinterStates.Printing :                        //While printing, wait for End of Print signal
													printerRibbonMovingTimer1.IN := ribbonEncoderPulseInput;
													printerRibbonMovingTimer2.IN := NOT ribbonEncoderPulseInput;
                                                    IF endOfPrintONS.Q OR printerRibbonMovingTimer1.Q OR printerRibbonMovingTimer2.Q THEN
                                                        startPrintOutput := FALSE;
                                                        lowerPrintHeadOutput := FALSE;
														IF printerRibbonMovingTimer1.Q OR printerRibbonMovingTimer2.Q THEN
															ribbonFault.Trigger();
														END_IF
														printerRibbonMovingTimer1.IN := FALSE;
														printerRibbonMovingTimer2.IN := FALSE;
														 
                                                        //oRunPrinterRibbonUnwindMotor := FALSE;
                                                        state := eZebraPrinterStates.DonePrinting;    
                                                    END_IF
                                        
    eZebraPrinterStates.DonePrinting :              //Done printing, feed a little more through
                                                     ribbonUnwindRunOutput := FALSE;
													 _printing := FALSE;
													 _printDone := TRUE;
                                                     state := eZebraPrinterStates.Idle;
                                                    
        
    eZebraPrinterStates.FeedThrough :                        
                                        
    eZebraPrinterStates.Ready :                        
                                        
    eZebraPrinterStates.Fault :              		// Clear status on fault
													_printing := FALSE;
													          
                                        
END_CASE