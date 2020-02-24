(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SimBasicPrinter EXTENDS FB_BaseComponent IMPLEMENTS IPrinter, IExecuteAutomatically
VAR_INPUT
	printSpeed : UDINT;
	printLength : REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	beginPrinting : FB_SimulatedFeedback(name := CONCAT(_prefix,'Begin Printing'));
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
