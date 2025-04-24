(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE OPC_Outputs :
STRUCT
	baggerOK : BOOL; // Bagger OK - Set high when Not Faulted
	readyForFiller : BOOL; // Ready for Filler - set high when ready for filler 
	printerDataReady : BOOL; // Printer Data Ready - set high when priter has a label
	waitingForPrinter : BOOL; // Waiting for Printer - set high when bagger is paused in cycle waiting for a label
	cycleComplete : BOOL; // Cycle Complete - pulsed when bagger cycle is complete (opened bag)
	bagMade : BOOL; // Bag Made - pulsed when bag is sealed and bag is dropping
	bagMadePlusLabelRequired : BOOL; // Bag Made - pulsed when bag is sealed and bag is dropping and bagger needs a label
	bagsLow : BOOL;	// Bags Low - set high when bag level is low
	readyForGrab : BOOL; // Ready for Grab - set high when bagger is ready for automation to grab bag
	runExternalExitConveyor : BOOL; // Run External Exit Conveyor - set high when external exit conveyor is called for
	heartbeatResponse : BOOL; // Heartbeat response - set equal to heartbeat
	activeFaultsList : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING; // Active Faults - list of active fault strings
	faultListTags : OPC_Faults;
END_STRUCT
END_TYPE
