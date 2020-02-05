(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE PRINTER_STATES :
(
	Idle := 0,
	WaitingForData := 1,
	DataReady := 2,
	BeginPrintCycle := 3,	
	FeedAtPrintSpeed := 10,
	Printing := 11,
	DonePrinting := 20,
	FeedThrough := 21,
	Ready := 40,
	Fault := 99
);
END_TYPE
