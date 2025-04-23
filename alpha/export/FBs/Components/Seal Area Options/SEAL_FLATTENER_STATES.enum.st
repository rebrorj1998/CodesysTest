(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'strict'}
{attribute 'qualified_only'}
TYPE SEAL_FLATTENER_STATES :
(
	Idle := 0,
	MoveFlattenersOut := 10,
	MovingFlattenersOut := 11,
	MovedFlattenersOut := 12,
	
	ShakeFlattenersToRelease := 13,
	
	MoveFlattenersUpAndToClearance := 20,
	MovingFlattenersUpAndToClearance := 21,
	MovedFlattenersUpAndToClearance := 22,
	
	MoveFlattenersToBagFeed := 23,
	MovingFlattenersToBagFeed := 24,
	MovedFlattenersToBagFeed := 25,
	
	MoveFlattenersIn := 30,
	MovingFlattenersIn := 31,
	MovedFlattenersIn := 32,
	
	MoveFlattenersDown := 40,
	MovingFlattenersDown := 41,
	MovedFlattenersDown := 42,
	
	MoveFlattenersToBagHolding := 50,
	MovingFlattenersToBagHolding := 51,
	MovedFlattenersToBagHolding := 52,
	
	MoveFlattenersInForFeedToSeal := 60,
	MovingFlattenersInForFeedToSeal := 61,
	MovedFlattenersInforFeedToSeal := 62,
	
	Ready := 60,
	Reset := 70,
	Resetting := 75,
	Fault := 99
);
END_TYPE
