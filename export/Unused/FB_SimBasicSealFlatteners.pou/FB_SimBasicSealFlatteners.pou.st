(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
