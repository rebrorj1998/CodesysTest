(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE AuxOutputSelection :
(
	NotConfigured := 0,
	PrinterDataReady := 1,
	WaitingForPrinter := 2,
	CycleComplete := 3,
	BagMade := 4,
	BagMadePlusLabelRequired := 5,
	BagsLow := 6,
	ReadyForGrab := 7
);
END_TYPE
