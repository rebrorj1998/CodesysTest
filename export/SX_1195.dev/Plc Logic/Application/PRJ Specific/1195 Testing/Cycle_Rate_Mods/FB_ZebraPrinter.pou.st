(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ZebraPrinter EXTENDS FB_BasicPrinter
VAR_INPUT
	printHeadDebounceSetting : TIME := T#20MS;
	printHeadDownInput : BOOL;
	dataReadyInput : BOOL;
	serviceRequiredInput : BOOL;
	eStopOK : BOOL;
	ribbonLowInput : BOOL;
	endOfPrintInput : BOOL;
	ribbonEncoderPulseInput : BOOL;
	serviceRaisePrintHead : BOOL;
	serviceLowerPrintHead : BOOL;
	cancelPrint : BOOL;
	dryCycleEnable : BOOL;
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
	raisePrintHeadDelay  : Standard.TON := (PT := T#75MS);
	endOfPrintONS : Standard.F_TRIG();
	printerRibbonMovingTimer1 : Standard.TON;
	printerRibbonMovingTimer2 : Standard.TON;
	printerRibbonMovingSettleTime : TIME := T#1H;//T#450MS;
	
	//variables for the state timer
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
	state_index : INT:=0;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_ZebraPrinter
//    Description: This program manages the aspects of a (Zebra) printer
//    Created by: Ben Hess
//    Created Date: April 2nd, 2018
SUPER^();

_hasLabel := dataReadyInput OR simulateIO OR dryCycleEnable;

endOfPrintONS(CLK := endOfPrintInput);
//Report as ready if mode is auto and we're not faulted
_ready := NOT (state = eZebraPrinterStates.Fault);

printerRibbonMovingTimer1(PT := printerRibbonMovingSettleTime);
printerRibbonMovingTimer2(PT := printerRibbonMovingSettleTime);

printerRibbonMovingTimer1(PT := T#1H);
printerRibbonMovingTimer2(PT := T#1H);


printHeadDebounce(PT:= printHeadDebounceSetting, Q=> printHeadDebounced);
raisePrintHeadDelay();

waitingForPrinter := state = eZebraPrinterStates.WaitingForData;
// printHeadLowerFaultTimer(IN := lowerPrintHeadOutput AND NOT printHeadDownInput);
// printHeadRaiseFaultTimer(IN := NOT lowerPrintHeadOutput AND printHeadDownInput);
// 
// IF printHeadLowerFaultTimer.Q AND THIS^.OptionActive THEN
// 	printHeadFailToLower.Trigger();
// END_IF
// 
// IF printHeadRaiseFaultTimer.Q AND THIS^.OptionActive THEN
// 	printHeadFailToRaise.Trigger();
// END_IF

IF NOT serviceRequiredInput AND eStopOK AND THIS^.OptionActive THEN
	serviceRequired.Trigger();
END_IF

resetONS(CLK := _reset);
IF enableONS.Q OR resetONS.Q THEN
    state := eZebraPrinterStates.Idle;
	_reset := FALSE;
	_beginPrinting := FALSE;
	_stopPrinting := FALSE;
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
//code to add timer to track duration in states
stateTimer(PT:=T#10000S);
IF clr THEN
	speedTracking:=speedTracking_mt;
	clr:=FALSE;
END_IF
IF state  = laststate THEN
	stateTimer.IN := TRUE;
ELSIF state  <> laststate THEN
	stateTimer.IN := FALSE;
	IF state =0 THEN
		count_index := count_index +1;
	END_IF
	laststate:=state;
END_IF
speedTracking[state_index][count_index] := stateTimer.ET;

IF count_index >=20 THEN
	count_index :=0;
END_IF
//End modded code
//State machine for the printer
CASE state OF
    eZebraPrinterStates.Idle :    
		state_index:=0;                        
		// Go to waiting for data if printer is ready
        ribbonUnwindRunOutput := FALSE;
		startPrintOutput := FALSE;
		printHeadDebounce.IN := FALSE;
		printHeadDebounced := FALSE;
		raisePrintHeadDelay.IN := FALSE;
		printerRibbonMovingTimer1.IN := FALSE;
		printerRibbonMovingTimer2.IN := FALSE;
		_printing := FALSE;
		_stopPrinting := FALSE;
		_printDone := FALSE;
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
                                        
    eZebraPrinterStates.WaitingForData:   
		state_index:=1;         
		// If printerDataReady drops out the label data was received
        IF dataReadyInput OR dryCycleEnable THEN
            state := eZebraPrinterStates.DataReady;    
        END_IF
		IF cancelPrint THEN
			state := eZebraPrinterStates.Idle;  
		END_IF
                                                
    eZebraPrinterStates.DataReady:     
		state_index:=2;                   
		// Wait for command to begin printing
         IF (NOT dataReadyInput AND NOT dryCycleEnable) OR cancelPrint THEN
			state := eZebraPrinterStates.Idle;
		END_IF
		IF _beginPrinting THEN
			 _printing := TRUE;
             _beginPrinting := FALSE;
			 printHeadDebounce.IN := TRUE;
             lowerPrintHeadOutput :=  NOT dryCycleEnable;
             ribbonUnwindRunOutput := NOT dryCycleEnable;
			 state := eZebraPrinterStates.BeginPrintCycle;
         END_IF                                    
            
    eZebraPrinterStates.BeginPrintCycle:        
		state_index:=3;   
		// Start printing
        IF printHeadDebounced THEN
            startPrintOutput := NOT dryCycleEnable;
            state := eZebraPrinterStates.Printing;
            printHeadDebounce.IN := FALSE;
        END_IF                                                    
                                                              
    eZebraPrinterStates.Printing:  
		state_index:=4;                      
		// While printing, wait for End of Print signal	
		printerRibbonMovingTimer1.IN := ribbonEncoderPulseInput;
		printerRibbonMovingTimer2.IN := NOT ribbonEncoderPulseInput;
        IF endOfPrintONS.q OR printerRibbonMovingTimer1.Q OR printerRibbonMovingTimer2.Q OR dryCycleEnable OR _stopPrinting THEN
            startPrintOutput := FALSE;
			_stopPrinting := FALSE;
			ribbonUnwindRunOutput := FALSE;
			IF printerRibbonMovingTimer1.Q OR printerRibbonMovingTimer2.Q THEN
				ribbonFault.Trigger();
			END_IF
			printerRibbonMovingTimer1.IN := FALSE;
			printerRibbonMovingTimer2.IN := FALSE;
			raisePrintHeadDelay.IN := TRUE;
            state := eZebraPrinterStates.DonePrinting;    
        END_IF
                                        
    eZebraPrinterStates.DonePrinting: 
		state_index:=5;             
		// Done printing, feed a little more through
		IF raisePrintHeadDelay.Q THEN
			raisePrintHeadDelay.IN := FALSE;
			lowerPrintHeadOutput := FALSE;
			_printing := FALSE;
			_printDone := TRUE;
			state := eZebraPrinterStates.Idle;
		END_IF                       
                                        
    eZebraPrinterStates.Fault:
		state_index:=6;              		
		// Clear status on fault
		_printing := FALSE;
													          
                                        
END_CASE