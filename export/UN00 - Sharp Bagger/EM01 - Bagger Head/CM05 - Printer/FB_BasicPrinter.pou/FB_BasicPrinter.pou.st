(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BasicPrinter EXTENDS FB_BaseComponent IMPLEMENTS IPrinter, ISimulateable
VAR_INPUT
	simulateIO : BOOL;
	printSpeed : UDINT;
	printLength : REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_hasLabel : BOOL;
	_printDone : BOOL;
	_beginPrinting : BOOL;
	_printing : BOOL;
	_simulate : BOOL;
	state : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();