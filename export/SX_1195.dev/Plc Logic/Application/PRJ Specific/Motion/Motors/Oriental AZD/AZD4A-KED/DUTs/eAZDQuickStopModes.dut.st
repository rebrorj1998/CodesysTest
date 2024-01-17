(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE eAZDQuickStopModes :
(
	CurrentOff := 0,
	ProfileDecelQSInactive := 1,
	QCDecelRateQSInactive:= 2,
	StopImmediateQSInactive := 3,
	ProfileDecelQSActive := 5,
	QCDecelRateQSActive := 6,
	StopImmediateQSActive := 7
);
END_TYPE
