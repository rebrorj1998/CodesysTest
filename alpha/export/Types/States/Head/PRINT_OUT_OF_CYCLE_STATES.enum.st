(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE PRINT_OUT_OF_CYCLE_STATES :
(
	Idle := 0,
	WaitForPrinter := 1,
	StartPrinting := 10,
	SendPrintSignal := 11, 
	Printing := 12, 
	FinishedPrinting := 13,
	WaitForTakeup := 14,
	Done := 100,
	Fault := 99
);
END_TYPE
