(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE FunnelSelection :
(
	NotInstalled := 0,
	FunnelWithSensors := 1,
	FunnelWithoutSensors := 2,
	TwoStageFunnelWithSensors := 3,
	BagLoadingTray := 4
);
END_TYPE
