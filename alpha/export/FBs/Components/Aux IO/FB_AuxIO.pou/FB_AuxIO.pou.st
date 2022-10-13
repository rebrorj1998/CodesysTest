(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_AuxIO
VAR_INPUT
	bagsLow : BOOL;
	configIn1 : BOOL;
	configIn2 : BOOL;
	configIn3 : BOOL;
	configIn4 : BOOL;
	faultActive : BOOL;
	inhibitCycle : BOOL;
	printerDataReady : BOOL;
	waitingForFiller : BOOL;
	state : StateMachine;
	factorySelection : AuxIOConfiguration;
	fillerType : REFERENCE TO FillerSelection;
END_VAR
VAR_OUTPUT
	baggerOK : BOOL;
	fillerOK : BOOL;
	configOut1 : BOOL;
	configOut2 : BOOL;
	bagGrabbed : BOOL;
	enableBagger : BOOL;
	inhibitBagger : BOOL;
	reverseConveyor : BOOL;
	readyForFiller : BOOL;
END_VAR
VAR
	_configOutputManager : FB_OutputPulseManager;
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

CASE factorySelection.factorySelection OF
	AuxiliaryIOSelection.NotInstalled:					
	
		// Turn outputs off
		baggerOK := FALSE;
		fillerOK := FALSE;
		bagGrabbed := FALSE;
		inhibitBagger := FALSE;
		readyForFiller := FALSE;
		
		// Reset pulse manager
		_configOutputManager.Reset();	
	
		// Turn Filler off if Aux IO is off
		IF __ISVALIDREF(fillerType) THEN
			fillerType := FillerSelection.NotInstalled;
		END_IF
		 
	AuxiliaryIOSelection.AuxIOStandard:					
		
		(* Inputs *)	
	
		// Baggers not faults and heated up.
		baggerOK := NOT faultActive;
		
		// Bags open and ready for filler.
		readyForFiller := waitingForFiller;
			 
        // Active if either input is set to 'FillerOK' and the corresponding input is active.
        fillerOK := InputActive(AuxInputSelection.FillerOK);
        
        // Active if either input is set to 'BaggerInhibit' and the corresponding input is active, or PAA enabled and inhibiting cycle.
        inhibitBagger := InputActive(AuxInputSelection.BagGrabbed) OR inhibitCycle;
		
		// Custom PRJ-22085: Robot successfully grabbed bag.
		bagGrabbed := InputActive(AuxInputSelection.BagGrabbed);
		
		// Custom PRJ-59126: Reverse BEC when high
		reverseConveyor := InputActive(AuxInputSelection.ReverseConveyor);
		
		// Custom PRJ-MFT01: Enable Bagger
	 	enableBagger := InputActive(AuxInputSelection.EnableBagger);
		
		(* Outputs *)
		
		// Custom PRJ22085: Ready For Grab
		IF waitingForFiller THEN
			_configOutputManager.Trigger(OutputSelected(AuxOutputSelection.ReadyForGrab)); 
		END_IF
		
		// Bags Low
		IF bagsLow THEN
			_configOutputManager.ManualOn(OutputSelected(AuxOutputSelection.BagsLow)); 
		ELSE
			_configOutputManager.ManualOff(OutputSelected(AuxOutputSelection.BagsLow)); 
		END_IF	
		
		// Cycle Complete
		IF state.head = HEAD_STATES.OpenedBag THEN
			_configOutputManager.Trigger(OutputSelected(AuxOutputSelection.CycleComplete));
		END_IF
		
		// Bag Made
		IF state.head = HEAD_STATES.SealedAndSeparatedBag THEN
			_configOutputManager.Trigger(OutputSelected(AuxOutputSelection.BagMade));
		END_IF		
	
		// Printer Data Ready
		IF printerDataReady THEN
			_configOutputManager.ManualOn(OutputSelected(AuxOutputSelection.PrinterDataReady)); 
		ELSE
			_configOutputManager.ManualOff(OutputSelected(AuxOutputSelection.PrinterDataReady)); 
		END_IF
		
		// Waiting For Printer
		IF state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter THEN
			_configOutputManager.ManualOn(OutputSelected(AuxOutputSelection.WaitingForPrinter)); 
		ELSE
			_configOutputManager.ManualOff(OutputSelected(AuxOutputSelection.WaitingForPrinter)); 
		END_IF
		
		// Bag Made Plus Label Required
		IF NOT printerDataReady AND state.head = HEAD_STATES.SealedAndSeparatedBag THEN
			_configOutputManager.ManualOn(OutputSelected(AuxOutputSelection.BagMadePlusLabelRequired)); 
		END_IF
				
		IF printerDataReady OR faultActive OR (state.sb.releaseFeed = RELEASE_FEED_STATES.FeedToOffset) THEN
			_configOutputManager.ManualOff(OutputSelected(AuxOutputSelection.BagMadePlusLabelRequired));
		END_IF									 
			
END_CASE 