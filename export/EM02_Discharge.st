

FUNCTION_BLOCK EM02_Discharge EXTENDS FB_PackMLStates IMPLEMENTS IEM02_Discharge
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR



{attribute 'monitoring' := 'call'}
PROPERTY OKToFeedBag : BOOL


{warning 'add property implementation'}
PROPERTY ReadyForProduct : BOOL


{warning 'add method implementation '}
METHOD TakeAwayBag
VAR_INPUT
		caller : IAllObjects;
END_VAR

