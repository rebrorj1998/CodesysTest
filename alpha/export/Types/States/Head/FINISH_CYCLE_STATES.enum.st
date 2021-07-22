(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'strict'}
TYPE FINISH_CYCLE_STATES :
(
	Idle := 0,
	Start := 1,
	OpenFunnel := 10, 
	OpeningFunnel := 11, 
	OpenedFunnel := 12,
	ClosingFunnelForRetry := 13,
	FunnelClosed := 14,
	BringSealFlattenersInAndDown := 20, 
	BringingSealFlattenersInAndDown := 21,
	SealFlattenersInAndDown := 22,
	BringSealFlattenersToBagHolding := 30,
	BringingSealFlattenersToBagHolding := 31,
	SealFlattenersAtBagHolding := 32,
	Shake := 33,
	Shaking := 34,
	Done := 100,
	Fault := 99
);
END_TYPE
