

FUNCTION_BLOCK FB_SimBasicSealFlatteners EXTENDS FB_BaseComponent IMPLEMENTS ISealFlatteners, IExecuteAutomatically
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_inPosition : BOOL;
	moveToBagFeed : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Bag Feed')) := (minDelay := 20, maxDelay := 100);
	moveToBagHolding : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Bag Holding')) := (minDelay := 190, maxDelay := 210);
	moveToClearance : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Clearance')) := (minDelay := 50, maxDelay := 70);
	moveToSeal : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Sealing')) := (minDelay := 200, maxDelay := 250);
	moveToIn : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to In')) := (minDelay := 200, maxDelay := 250);
	okayToMove : BOOL;
END_VAR



{attribute 'monitoring' := 'variable'}
PROPERTY InPosition : BOOL


METHOD ToSeal

ClearStatus();
moveToSeal.in := TRUE;

METHOD ToClearance

ClearStatus();
moveToClearance.in := TRUE;

METHOD ToBagFeed

ClearStatus();
moveToBagFeed.in := TRUE;

METHOD ToIn

ClearStatus();
moveToIn.in := TRUE;

METHOD BagIsOpen

ClearStatus();
moveToBagHolding.in := TRUE;

METHOD Execute

SUPER^.Execute();
moveToBagFeed();
moveToBagHolding();
moveToClearance();
moveToSeal();
moveToIn();

METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR

moveToBagFeed.in := FALSE;
moveToBagHolding.in := FALSE;
moveToClearance.in := FALSE;
moveToSeal.in := FALSE;
moveToIn.in := FALSE;
THIS^.Execute();

FUNCTION_BLOCK FB_SimBasicSealFlatteners EXTENDS FB_BaseComponent IMPLEMENTS ISealFlatteners, IExecuteAutomatically
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_inPosition : BOOL;
	moveToBagFeed : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Bag Feed')) := (minDelay := 20, maxDelay := 100);
	moveToBagHolding : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Bag Holding')) := (minDelay := 190, maxDelay := 210);
	moveToClearance : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Clearance')) := (minDelay := 50, maxDelay := 70);
	moveToSeal : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to Sealing')) := (minDelay := 200, maxDelay := 250);
	moveToIn : FB_SimulatedFeedback(name := CONCAT(_prefix,'Move to In')) := (minDelay := 200, maxDelay := 250);
	okayToMove : BOOL;
END_VAR



{attribute 'monitoring' := 'variable'}
PROPERTY InPosition : BOOL


METHOD ToSeal

ClearStatus();
moveToSeal.in := TRUE;

METHOD ToClearance

ClearStatus();
moveToClearance.in := TRUE;

METHOD ToBagFeed

ClearStatus();
moveToBagFeed.in := TRUE;

METHOD ToIn

ClearStatus();
moveToIn.in := TRUE;

METHOD BagIsOpen

ClearStatus();
moveToBagHolding.in := TRUE;

METHOD Execute

SUPER^.Execute();
moveToBagFeed();
moveToBagHolding();
moveToClearance();
moveToSeal();
moveToIn();

METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR

moveToBagFeed.in := FALSE;
moveToBagHolding.in := FALSE;
moveToClearance.in := FALSE;
moveToSeal.in := FALSE;
moveToIn.in := FALSE;
THIS^.Execute();