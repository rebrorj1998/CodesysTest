(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL


//Inputs
	bagsLow : BOOL;
	inhibitCycle : BOOL;
	printerDataReady : BOOL;
	runExitConveyor : BOOL;
	heartbeat : BOOL;
	
// Outputs	
	baggerOK : BOOL;
	fillerOK : BOOL;
	bagGrabbed : BOOL;
	enableBagger : BOOL;
	inhibitBagger : BOOL;
	reverseConveyor : BOOL;
	readyForFiller : BOOL;
	cycleComplete : BOOL;
	bagMade : BOOL;
	waitingForPrinter : BOOL;
	bagMadePlusLabelRequired : BOOL;
	activeFaults : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;

END_VAR