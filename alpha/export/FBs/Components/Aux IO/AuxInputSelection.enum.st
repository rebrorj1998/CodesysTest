(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE AuxInputSelection :
(
	NotConfigured := 0,
	BaggerInhibit := 1,
	CollisionDetection := 2,
	ConveyorFaulted := 3,
	FillerOK := 4,
	EnableBagger := 5,
	ReverseConveyor := 6,
	BagGrabbed := 7
);
END_TYPE
